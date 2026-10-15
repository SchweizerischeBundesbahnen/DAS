// main-idempotence.property.test.mjs
//
// End-to-end property test exercising main() for the idempotence of repeated
// switches.
//
// Feature: flavor-code-switching, Property 8: Idempotence of repeated switches:
// for any flavor and fixture, running the switch for that flavor twice produces
// an identical set of lib/ target files (same paths, byte-identical content)
// and an identical manifest (same flavor and same files set) after the second
// run as after the first. The manifest's generatedAt timestamp MAY differ
// between runs and is deliberately excluded from the comparison.
//
// Validates: Requirements 5.1
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import crypto from 'node:crypto';
import path from 'node:path';

import { main, FLAVORS, MANIFEST_FILENAME } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

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
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content — may include non-ASCII bytes and newlines. */
function randomContent() {
  const kind = randInt(3);
  if (kind === 0) return ''; // empty file
  const len = randIntRange(1, 64);
  if (kind === 1) {
    let s = '';
    const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    return s;
  }
  let s = '';
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/** Build unique component names, avoiding `app` (the helper always creates it). */
function uniqueNames(count) {
  const taken = new Set(['app']);
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
 * Build a random nested tree of files keyed by relative POSIX path.
 * Guarantees at least one file so the owning component contributes a copy.
 * @returns {Record<string,string>}
 */
function randomFileTree() {
  const fileCount = randIntRange(1, 6);
  const tree = {};
  const dirPool = [''];
  const extraDirs = randInt(3);
  for (let i = 0; i < extraDirs; i++) {
    const depth = randIntRange(1, 3);
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
    dirPool.push(segs.join('/'));
  }

  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10) {
    attempts++;
    const dir = pick(dirPool);
    const fileName = `${randomName(1, 8)}.dart`;
    const rel = dir === '' ? fileName : `${dir}/${fileName}`;
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent();
  }
  return tree;
}

/**
 * Build a random repo spec where at least one component owns a folder for the
 * chosen flavor (so the copy plan is non-empty and main returns 0). Some
 * components get other-flavor folders or no flavor folder as noise.
 * @param {string} flavor
 */
function buildSpec(flavor) {
  const otherFlavors = FLAVORS.filter((f) => f !== flavor);
  const names = uniqueNames(randIntRange(2, 5));

  const components = [];
  let owners = 0;

  for (let i = 0; i < names.length; i++) {
    const name = names[i];
    const roll = Math.random();
    // Force the last component to own the flavor if none has so far.
    const mustOwn = owners === 0 && i === names.length - 1;

    if (mustOwn || roll < 0.6) {
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: randomFileTree() },
      });
      owners++;
    } else if (roll < 0.8) {
      // lib/ only, no flavor folder.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
      });
    } else {
      // Only a different flavor's folder.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [pick(otherFlavors)]: randomFileTree() },
      });
    }
  }

  return { components };
}

/** Read the manifest JSON directly from disk. */
async function readManifestJson(repoRoot) {
  const raw = await fsp.readFile(path.join(repoRoot, MANIFEST_FILENAME), 'utf8');
  return JSON.parse(raw);
}

/**
 * Snapshot the set of copied lib/ target files (from the manifest's files list)
 * as a sorted array of `path -> sha256(content)` entries. Reading from the
 * manifest's recorded files makes this a faithful snapshot of the switch's
 * target set and their on-disk bytes.
 * @param {string} repoRoot
 * @param {string[]} files repo-relative POSIX target paths (already `.path`-mapped)
 */
async function snapshotTargets(repoRoot, files) {
  const entries = [];
  for (const rel of [...files].sort()) {
    const abs = path.resolve(repoRoot, rel);
    const buf = await fsp.readFile(abs);
    const hash = crypto.createHash('sha256').update(buf).digest('hex');
    entries.push(`${rel}\u0000${hash}`);
  }
  return entries;
}

test('Property 8: running the switch for a flavor twice yields identical lib/ targets and manifest', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-idempotence-prop-');
    try {
      const flavor = pick(FLAVORS);
      const spec = buildSpec(flavor);
      await buildRepo(repoRoot, spec);

      const argv = ['node', 'switch-flavor.mjs', flavor];
      const ctx = `iter=${i} flavor='${flavor}'`;

      // First run.
      const code1 = main(argv, { repoRoot });
      assert.equal(code1, 0, `first run must exit 0 (${ctx})`);

      // Manifest is schema v2: `files` is an array of `{ path, overwrote }`.
      const manifest1 = await readManifestJson(repoRoot);
      assert.equal(manifest1.version, 2, `first manifest.version must be 2 (${ctx})`);
      const paths1 = manifest1.files.map((e) => e.path);
      const files1 = [...paths1].sort();
      const targets1 = await snapshotTargets(repoRoot, paths1);

      // Second run against the exact same repo state.
      const code2 = main(argv, { repoRoot });
      assert.equal(code2, 0, `second run must exit 0 (${ctx})`);

      const manifest2 = await readManifestJson(repoRoot);
      assert.equal(manifest2.version, 2, `second manifest.version must be 2 (${ctx})`);
      const paths2 = manifest2.files.map((e) => e.path);
      const files2 = [...paths2].sort();
      const targets2 = await snapshotTargets(repoRoot, paths2);

      // Manifest flavor is identical.
      assert.equal(
        manifest2.flavor,
        manifest1.flavor,
        `manifest flavor must be identical after the second run (${ctx})`,
      );
      assert.equal(manifest2.flavor, flavor, `manifest flavor must be the chosen flavor (${ctx})`);

      // Manifest files set is identical (timestamp may differ, not compared).
      assert.deepEqual(
        files2,
        files1,
        `manifest files set must be identical after the second run (${ctx})`,
      );

      // The copied lib/ target files set and their byte contents are identical.
      assert.deepEqual(
        targets2,
        targets1,
        `copied lib/ target files and contents must be identical after the second run (${ctx})`,
      );

      // Sanity: there is at least one copied target (non-empty plan).
      assert.ok(files1.length > 0, `expected at least one copied target (${ctx})`);
      // Every recorded target must exist on disk after the second run.
      for (const rel of paths2) {
        assert.ok(
          fs.existsSync(path.resolve(repoRoot, rel)),
          `recorded target '${rel}' must exist on disk (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
