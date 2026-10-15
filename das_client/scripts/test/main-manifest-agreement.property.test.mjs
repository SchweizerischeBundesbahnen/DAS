// main-manifest-agreement.property.test.mjs
//
// Property test for the end-to-end main() orchestration: the written manifest
// must describe exactly the files copied into lib/, every such file must exist
// on disk, and manifest.flavor must equal the selected flavor.
//
// Feature: flavor-code-switching, Property 4: Manifest describes exactly the
// copied, on-disk targets: for any successful switch, the set of repo-relative
// paths in manifest.files equals the set of files actually copied into lib/,
// every such file exists on disk after the switch, and manifest.flavor equals
// the selected flavor.
//
// Validates: Requirements 2.1, 2.2, 9.2
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';

import { FLAVORS, main, MANIFEST_FILENAME } from '../switch-flavor.mjs';
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

/**
 * Build a set of unique component names so no two collide.
 * @param {number} count
 * @param {Set<string>} taken names already in use
 */
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
 * @returns {Record<string,string>}
 */
function randomFileTree() {
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
    tree[rel] = `// ${rel}\nvar v = ${randInt(1000)};\n`;
  }
  return tree;
}

/**
 * Build one random miniature-repo spec guaranteed to have at least one
 * component owning the selected flavor folder (so the switch succeeds), plus a
 * mix of non-matching components.
 *
 * @param {string} flavor the selected flavor
 * @returns {{ spec: object, expectedTargets: Set<string> }}
 *   expectedTargets is the set of repo-relative POSIX paths that SHOULD be
 *   copied into lib/ (derived from the fixture).
 */
function buildSpec(flavor) {
  const taken = new Set(['app']); // helper always creates `app`.
  const otherFlavors = FLAVORS.filter((f) => f !== flavor);

  const componentCount = randIntRange(3, 7);
  const names = uniqueNames(componentCount, taken);

  const components = [];
  const expectedTargets = new Set();

  // Guarantee at least one owner of the selected flavor so main() succeeds.
  let ownerCount = 0;

  for (let idx = 0; idx < names.length; idx++) {
    const name = names[idx];
    const forceOwner = idx === names.length - 1 && ownerCount === 0;
    const roll = forceOwner ? 0 : Math.random();

    if (roll < 0.45) {
      // Owns the selected flavor folder → contributes to lib/.
      const tree = randomFileTree();
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: tree },
      });
      for (const rel of Object.keys(tree)) {
        expectedTargets.add(`${name}/lib/${rel}`);
      }
      ownerCount++;
    } else if (roll < 0.65) {
      // lib/ but no flavor folder → contributes nothing.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
      });
    } else if (roll < 0.82) {
      // Owns only a DIFFERENT flavor folder → contributes nothing.
      const other = pick(otherFlavors);
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [other]: randomFileTree() },
      });
    } else {
      // Owns BOTH the selected flavor AND another → only the selected flavor's
      // files are copied.
      const tree = randomFileTree();
      const other = pick(otherFlavors);
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: tree, [other]: randomFileTree() },
      });
      for (const rel of Object.keys(tree)) {
        expectedTargets.add(`${name}/lib/${rel}`);
      }
      ownerCount++;
    }
  }

  return { spec: { components }, expectedTargets };
}

/**
 * Recursively collect every file beneath `dir`, returned as POSIX paths
 * relative to `base`.
 * @param {string} dir absolute directory to walk
 * @param {string} base absolute base for relativization
 * @returns {Promise<string[]>}
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

test('Property 4: manifest describes exactly the copied, on-disk lib/ targets', async () => {
  // Keep stdout/stderr quiet during the end-to-end runs; main() logs a summary.
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};

  try {
    for (let i = 0; i < ITERATIONS; i++) {
      const flavor = pick(FLAVORS);
      const { spec, expectedTargets } = buildSpec(flavor);

      const dir = await makeTempDir();
      try {
        await buildRepo(dir, spec);

        const ctx = `iteration=${i} flavor='${flavor}'`;

        // Record the lib/ files present BEFORE the switch so we can isolate the
        // files actually copied by this switch (the placeholders already exist).
        const preLibFiles = new Set();
        for (const comp of spec.components) {
          const libDir = path.join(dir, comp.name, 'lib');
          for (const rel of await listFilesRel(libDir, dir)) preLibFiles.add(rel);
        }

        // Run the end-to-end switch. No spawn needed (no --remove-dep).
        const code = main(['node', 'switch-flavor.mjs', flavor], { repoRoot: dir });
        assert.equal(code, 0, `main() must succeed for a valid flavor switch (${ctx})`);

        // Read the manifest written by the switch.
        const manifestPath = path.join(dir, MANIFEST_FILENAME);
        const manifestText = await fs.readFile(manifestPath, 'utf8');
        const manifest = JSON.parse(manifestText);

        // manifest.flavor must equal the selected flavor (Req 2.2).
        assert.equal(
          manifest.flavor,
          flavor,
          `manifest.flavor must equal the selected flavor (${ctx})`,
        );

        // manifest is schema v2: `files` is an array of `{ path, overwrote }`
        // entries. Compare path sets.
        assert.equal(manifest.version, 2, `manifest.version must be 2 (${ctx})`);
        const manifestPaths = manifest.files.map((e) => e.path);

        // manifest.files must equal EXACTLY the expected copied targets (Req 2.1).
        const manifestFiles = [...manifestPaths].sort();
        const expectedSorted = [...expectedTargets].sort();
        assert.deepEqual(
          manifestFiles,
          expectedSorted,
          `manifest.files must equal exactly the expected copied targets (${ctx})`,
        );

        // The set of files actually added to lib/ by the switch must equal the
        // manifest set (manifest describes exactly the copied targets).
        const postLibFiles = new Set();
        for (const comp of spec.components) {
          const libDir = path.join(dir, comp.name, 'lib');
          for (const rel of await listFilesRel(libDir, dir)) postLibFiles.add(rel);
        }
        const copiedBySwitch = [...postLibFiles].filter((f) => !preLibFiles.has(f)).sort();
        assert.deepEqual(
          copiedBySwitch,
          expectedSorted,
          `files newly present in lib/ must equal the manifest set (${ctx})`,
        );

        // Every manifest.files path must exist on disk after the switch (Req 9.2).
        for (const rel of manifestPaths) {
          const abs = path.resolve(dir, rel);
          let stat;
          try {
            stat = await fs.stat(abs);
          } catch {
            assert.fail(`manifest path '${rel}' must exist on disk after the switch (${ctx})`);
          }
          assert.ok(stat.isFile(), `manifest path '${rel}' must be a file (${ctx})`);
        }
      } finally {
        await removeTempDir(dir);
      }
    }
  } finally {
    console.log = origLog;
    console.error = origError;
  }
});
