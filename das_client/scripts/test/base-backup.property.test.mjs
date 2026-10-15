// base-backup.property.test.mjs
//
// Property test for the end-to-end main() switch: the Base_Backup_Directory must
// capture EXACTLY the base files that the switch overwrote, byte-for-byte in
// their ORIGINAL (pre-switch) content, and the manifest's `overwrote` flag must
// classify each target correctly (true for overwritten base files, false for
// newly-created files).
//
// Feature: flavor-code-switching, Property 13: Base backup captures exactly the
// overwritten base files.
//
// For any successful switch, for every flavor target that overwrote a
// pre-existing lib/ base file there is a byte-identical Base_Backup_File at the
// mirrored path under .flavor-base-backup/ holding the ORIGINAL base content
// (not the flavor content), and every target with `overwrote: true` in the
// manifest; for every new target (no pre-existing lib/ file) there is NO backup
// and `overwrote: false`; and the backup dir contains no extra files beyond the
// overwritten set.
//
// Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';

import { FLAVORS, main, MANIFEST_FILENAME, BASE_BACKUP_DIRNAME } from '../switch-flavor.mjs';
import { makeTempDir, buildRepo, removeTempDir } from './helpers.mjs';

const ITERATIONS = 120; // >= 100 minimum per the plan.

/** Random integer in [0, maxExclusive). */
function randInt(maxExclusive) {
  return Math.floor(Math.random() * maxExclusive);
}

/** Random integer in [min, max]. */
function randIntRange(min, max) {
  return min + randInt(max - min + 1);
}

/** Pick a random element of an array. */
function pick(arr) {
  return arr[randInt(arr.length)];
}

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 3, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Build a set of unique names so no two collide. */
function uniqueNames(count, taken) {
  const names = [];
  while (names.length < count) {
    const n = randomName();
    if (taken.has(n)) continue;
    taken.add(n);
    names.push(n);
  }
  return names;
}

/**
 * Build a random nested tree of small files, keyed by relative POSIX path.
 * Guarantees at least one file so the owning component always contributes.
 * `tag` is woven into the content so flavor vs base content never accidentally
 * coincide.
 * @param {string} tag
 * @returns {Record<string,string>}
 */
function randomFileTree(tag) {
  const fileCount = randIntRange(1, 4);
  const tree = {};
  let guard = 0;
  while (Object.keys(tree).length < fileCount && guard < 20) {
    guard++;
    const depth = randIntRange(0, 2);
    const segments = [];
    for (let d = 0; d < depth; d++) segments.push(randomName(2, 5));
    segments.push(`${randomName(2, 6)}.dart`);
    const rel = segments.join('/');
    if (tree[rel] !== undefined) continue; // skip accidental collisions
    tree[rel] = `// ${tag} ${rel}\nvar v = ${randInt(1000000)};\n`;
  }
  return tree;
}

/**
 * Build one random miniature-repo spec. At least one component owns the selected
 * flavor folder (so the switch succeeds). For each flavor target an arbitrary
 * SUBSET is pre-created as a DIFFERENT-content base file at the lib/ path (these
 * will be OVERWRITTEN); the complement are NEW targets (no pre-existing lib/
 * file). Mixed in are non-matching components as noise.
 *
 * @param {string} flavor the selected flavor
 * @returns {{ spec: object, overwritten: Set<string>, created: Set<string>,
 *            originalBase: Map<string,string> }}
 *   - overwritten: repo-relative POSIX targets that will overwrite a base file
 *   - created:     repo-relative POSIX targets that are new (no base file)
 *   - originalBase: repo-relative target -> ORIGINAL base content (overwritten only)
 */
function buildSpec(flavor) {
  const taken = new Set(['app']); // helper always creates `app`.
  const otherFlavors = FLAVORS.filter((f) => f !== flavor);

  const componentCount = randIntRange(2, 6);
  const names = uniqueNames(componentCount, taken);

  const components = [];
  const overwritten = new Set();
  const created = new Set();
  const originalBase = new Map();

  let ownerCount = 0;

  for (let idx = 0; idx < names.length; idx++) {
    const name = names[idx];
    const forceOwner = idx === names.length - 1 && ownerCount === 0;
    const roll = forceOwner ? 0 : Math.random();

    if (roll < 0.6) {
      // Owns the selected flavor folder → contributes to lib/.
      const tree = randomFileTree(`flavor:${flavor}`);
      const libSeed = {};
      for (const rel of Object.keys(tree)) {
        const target = `${name}/lib/${rel}`;
        // Arbitrary subset: pre-create a DIFFERENT-content base file so the
        // switch OVERWRITES it. The complement are NEW targets.
        if (Math.random() < 0.5) {
          const base = `// base:${name} ${rel}\nvar base = ${randInt(1000000)};\n`;
          libSeed[rel] = base;
          overwritten.add(target);
          originalBase.set(target, base);
        } else {
          created.add(target);
        }
      }
      components.push({
        name,
        // Always include a placeholder so lib/ is non-empty and the component
        // qualifies for discovery even if no base files were seeded.
        lib: { 'placeholder.dart': '// placeholder\n', ...libSeed },
        flavors: { [flavor]: tree },
      });
      ownerCount++;
    } else if (roll < 0.78) {
      // lib/ but no flavor folder → contributes nothing.
      components.push({ name, lib: { 'placeholder.dart': '// placeholder\n' } });
    } else {
      // Owns only a DIFFERENT flavor folder → contributes nothing.
      const other = pick(otherFlavors);
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [other]: randomFileTree(`flavor:${other}`) },
      });
    }
  }

  return { spec: { components }, overwritten, created, originalBase };
}

/**
 * Recursively collect every file beneath `dir`, returned as POSIX paths
 * relative to `base`.
 */
async function listFilesRel(dir, base) {
  const out = [];
  let entries;
  try {
    entries = await fs.readdir(dir, { withFileTypes: true });
  } catch (err) {
    if (err && err.code === 'ENOENT') return out;
    throw err;
  }
  for (const entry of entries) {
    const abs = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...(await listFilesRel(abs, base)));
    } else if (entry.isFile()) {
      out.push(path.relative(base, abs).split(path.sep).join('/'));
    }
  }
  return out;
}

test('Property 13: base backup captures exactly the overwritten base files', async () => {
  // Keep stdout/stderr quiet during the end-to-end runs; main() logs a summary.
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};

  try {
    for (let i = 0; i < ITERATIONS; i++) {
      const flavor = pick(FLAVORS);
      const { spec, overwritten, created, originalBase } = buildSpec(flavor);

      const dir = await makeTempDir();
      try {
        await buildRepo(dir, spec);

        const ctx = `iteration=${i} flavor='${flavor}'`;

        // Run the end-to-end switch. No spawn needed (no --remove-dep).
        const code = main(['node', 'switch-flavor.mjs', flavor], { repoRoot: dir });
        assert.equal(code, 0, `main() must succeed for a valid flavor switch (${ctx})`);

        // Read the manifest written by the switch.
        const manifestText = await fs.readFile(path.join(dir, MANIFEST_FILENAME), 'utf8');
        const manifest = JSON.parse(manifestText);
        assert.equal(manifest.version, 2, `manifest.version must be 2 (${ctx})`);

        // Classification (Req 10.3/10.4): overwrote === true exactly for the
        // overwritten targets, false exactly for the new targets.
        const manifestOverwrote = new Map(manifest.files.map((e) => [e.path, e.overwrote]));
        const expectedOverwrote = [...overwritten].sort();
        const actualOverwrote = manifest.files
          .filter((e) => e.overwrote === true)
          .map((e) => e.path)
          .sort();
        assert.deepEqual(
          actualOverwrote,
          expectedOverwrote,
          `manifest entries with overwrote=true must equal exactly the overwritten targets (${ctx})`,
        );

        const expectedCreated = [...created].sort();
        const actualCreated = manifest.files
          .filter((e) => e.overwrote === false)
          .map((e) => e.path)
          .sort();
        assert.deepEqual(
          actualCreated,
          expectedCreated,
          `manifest entries with overwrote=false must equal exactly the new targets (${ctx})`,
        );

        const backupRoot = path.join(dir, BASE_BACKUP_DIRNAME);

        // For every OVERWRITTEN target: a Base_Backup_File exists at the mirrored
        // path and is byte-identical to the ORIGINAL base content (Req 10.1/10.5).
        for (const target of overwritten) {
          assert.equal(
            manifestOverwrote.get(target),
            true,
            `overwritten target '${target}' must be classified overwrote=true (${ctx})`,
          );
          const backupAbs = path.join(backupRoot, ...target.split('/'));
          let backupContent;
          try {
            backupContent = await fs.readFile(backupAbs, 'utf8');
          } catch {
            assert.fail(`backup file must exist for overwritten target '${target}' (${ctx})`);
          }
          assert.equal(
            backupContent,
            originalBase.get(target),
            `backup for '${target}' must hold the ORIGINAL base content, not the flavor content (${ctx})`,
          );
        }

        // For every NEW target: NO backup file exists under the backup dir.
        for (const target of created) {
          assert.equal(
            manifestOverwrote.get(target),
            false,
            `new target '${target}' must be classified overwrote=false (${ctx})`,
          );
          const backupAbs = path.join(backupRoot, ...target.split('/'));
          let exists = true;
          try {
            await fs.access(backupAbs);
          } catch {
            exists = false;
          }
          assert.equal(exists, false, `new target '${target}' must have NO backup file (${ctx})`);
        }

        // No EXTRA files in the backup dir beyond the overwritten set (Req 10.2).
        const backupFiles = (await listFilesRel(backupRoot, backupRoot))
          .map((p) => p.split(path.sep).join('/'))
          .sort();
        assert.deepEqual(
          backupFiles,
          expectedOverwrote,
          `backup dir must contain exactly the overwritten targets, no extras (${ctx})`,
        );
      } finally {
        await removeTempDir(dir);
      }
    }
  } finally {
    console.log = origLog;
    console.error = origError;
  }
});
