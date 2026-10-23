// main-no-mutation.property.test.mjs
//
// End-to-end property test for main(): invalid input must mutate nothing.
//
// Feature: flavor-code-switching, Property 9: No mutation on invalid input:
// invoking main() with a missing flavor positional, or a positional that is not
// one of ['dev','inte','prod'], leaves every lib/ folder, the manifest, and
// app/pubspec.yaml byte-identical and returns a non-zero exit code. Nothing is
// created, deleted, or modified anywhere in the repo tree; if no manifest
// existed before, none is created.
//
// Validates: Requirements 6.1, 6.2, 6.4
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

import { main, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

const ITERATIONS = 150; // >= 100 minimum per the plan.

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
function randomName(minLen = 1, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content, may include unicode and newlines to exercise bytes. */
function randomContent() {
  const kind = randInt(3);
  if (kind === 0) return ''; // empty file
  const len = randIntRange(1, 48);
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

/** Build a random map of POSIX relative path -> content (possibly empty). */
function randomTree(minFiles = 0, maxFiles = 5) {
  const fileCount = randIntRange(minFiles, maxFiles);
  const tree = {};
  const dirPool = [''];
  const extraDirs = randInt(3);
  for (let i = 0; i < extraDirs; i++) {
    const depth = randIntRange(1, 2);
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 5));
    dirPool.push(segs.join('/'));
  }
  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10 + 10) {
    attempts++;
    const dir = pick(dirPool);
    const fileName = `${randomName(1, 6)}.dart`;
    const rel = dir === '' ? fileName : `${dir}/${fileName}`;
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent();
  }
  return tree;
}

/**
 * Build a random repo spec: 0..3 components, each may have a lib/ with
 * pre-existing files and may own one or more flavor folders. Returns the spec
 * passed to buildRepo plus a flag whether a manifest was requested.
 */
function randomRepoSpec() {
  const componentCount = randIntRange(0, 3);
  const components = [];
  const usedNames = new Set();
  for (let i = 0; i < componentCount; i++) {
    let name = randomName(3, 10);
    while (usedNames.has(name)) name = randomName(3, 10);
    usedNames.add(name);

    const flavors = {};
    // Give some components one or more real flavor folders so that, were the
    // input valid, a mutation WOULD occur. The invalid input must prevent it.
    const flavorSubset = FLAVORS.filter(() => Math.random() < 0.5);
    for (const f of flavorSubset) {
      flavors[f] = randomTree(1, 4);
    }

    components.push({
      name,
      lib: randomTree(0, 4),
      flavors,
    });
  }

  const spec = { components };

  // Optionally pre-seed a manifest: a valid one, a corrupt one, or none.
  const manifestKind = randInt(3);
  if (manifestKind === 1) {
    spec.manifest = {
      version: 1,
      flavor: pick(FLAVORS),
      generatedAt: new Date().toISOString(),
      files: Object.keys(randomTree(0, 3)),
    };
  } else if (manifestKind === 2) {
    spec.manifestRaw = `{ not valid json ${randomName(2, 6)}`;
  }

  return spec;
}

/**
 * Walk every file in `root` recursively and return a sorted map of
 * repo-relative POSIX path -> sha256 hash (hex) of the bytes. Captures the full
 * file SET and byte content, so any create/delete/modify shows up as a diff.
 */
async function snapshotTree(root) {
  const { createHash } = await import('node:crypto');
  const snapshot = {};

  const walk = (absDir) => {
    const dirents = fs.readdirSync(absDir, { withFileTypes: true });
    for (const dirent of dirents) {
      const abs = path.join(absDir, dirent.name);
      if (dirent.isDirectory()) {
        walk(abs);
      } else if (dirent.isFile()) {
        const rel = path.relative(root, abs).split(path.sep).join('/');
        const buf = fs.readFileSync(abs);
        snapshot[rel] = createHash('sha256').update(buf).digest('hex');
      }
    }
  };
  walk(root);
  return snapshot;
}

/**
 * Build an invalid argv (node, script, ...args). Either omits the flavor
 * positional entirely, or supplies a positional that is not a valid flavor.
 * Never uses --help (that is a valid success path).
 */
function invalidArgv() {
  const mode = randInt(2);
  const base = ['node', 'switch-flavor.mjs'];
  if (mode === 0) {
    // No flavor positional. Optionally pass a --remove-dep flag (still invalid
    // because the required flavor is missing).
    if (Math.random() < 0.5) base.push(`--remove-dep=${randomName(3, 8)}`);
    return base;
  }
  // A non-flavor positional. Keep generating until it is NOT a valid flavor.
  let candidate = randomName(1, 12);
  while (FLAVORS.includes(candidate)) candidate = randomName(1, 12);
  base.push(candidate);
  if (Math.random() < 0.5) base.push(`--remove-dep=${randomName(3, 8)}`);
  return base;
}

/** Silence main()'s console output for the duration of `fn`. */
async function withSilencedConsole(fn) {
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};
  try {
    return await fn();
  } finally {
    console.log = origLog;
    console.error = origError;
  }
}

test('Property 9: main() with invalid input mutates nothing and exits non-zero', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-nomutate-prop-');
    try {
      const spec = randomRepoSpec();
      await buildRepo(repoRoot, spec);

      const manifestExistedBefore = fs.existsSync(
        path.join(repoRoot, '.flavor-manifest.json'),
      );

      // Full snapshot BEFORE: every file path -> content hash.
      const before = await snapshotTree(repoRoot);

      const argv = invalidArgv();
      const ctx = `iter=${i} argv=${JSON.stringify(argv.slice(2))}`;

      // A spawn stub that would make noise if ever called — invalid input must
      // never reach workspace resolution.
      let spawnCalled = false;
      const spawn = () => {
        spawnCalled = true;
        return { status: 0 };
      };

      const code = await withSilencedConsole(() => main(argv, { repoRoot, spawn }));

      // Non-zero exit code (the single failure code is 1).
      assert.equal(code, 1, `invalid input must return non-zero exit code (${ctx})`);
      assert.equal(spawnCalled, false, `resolution must not be spawned (${ctx})`);

      // Full snapshot AFTER must equal the snapshot BEFORE — same file set and
      // byte-identical content. deepEqual over the hash maps proves nothing was
      // created, deleted, or modified anywhere in the tree.
      const after = await snapshotTree(repoRoot);
      assert.deepEqual(after, before, `repo tree must be byte-identical after invalid input (${ctx})`);

      // Manifest existence must be unchanged (no manifest created if none existed).
      const manifestExistsAfter = fs.existsSync(path.join(repoRoot, '.flavor-manifest.json'));
      assert.equal(
        manifestExistsAfter,
        manifestExistedBefore,
        `manifest existence must be unchanged (${ctx})`,
      );
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
