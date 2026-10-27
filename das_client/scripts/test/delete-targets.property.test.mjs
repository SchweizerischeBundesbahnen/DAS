// delete-targets.property.test.mjs
//
// Property test for deleteTargets bounded, complete deletion.
//
// Feature: flavor-code-switching, Property 5: Deletion is bounded by and
// complete over the manifest: for a switch performed with a valid prior
// manifest, the set of files deleted is exactly the manifest-listed paths that
// exist on disk — every listed existing path is removed (and reported in
// result.deleted), every listed path that is absent is reported in
// result.skipped, and NO file outside the manifest list is removed (every
// non-listed file survives byte-identical).
//
// Validates: Requirements 3.1, 3.2
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';

import { deleteTargets } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir } from './helpers.mjs';

const ITERATIONS = 150; // >= 100 minimum per the plan.

/** Random integer in [0, maxExclusive). */
function randInt(maxExclusive) {
  return Math.floor(Math.random() * maxExclusive);
}

/** Random integer in [min, max]. */
function randIntRange(min, max) {
  return min + randInt(max - min + 1);
}

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 3, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/**
 * Build a unique repo-relative POSIX path with a random (possibly nested)
 * directory structure, avoiding collisions with already-used paths.
 * @param {Set<string>} taken
 * @returns {string}
 */
function uniqueRelPath(taken) {
  while (true) {
    const depth = randIntRange(0, 3);
    const segments = [];
    for (let d = 0; d < depth; d++) segments.push(randomName());
    segments.push(`${randomName()}.dart`);
    const rel = segments.join('/');
    if (!taken.has(rel)) {
      taken.add(rel);
      return rel;
    }
  }
}

/**
 * Create a file (with parent dirs) under the repo root, writing random content.
 * @param {string} repoRoot
 * @param {string} rel repo-relative POSIX path
 * @returns {Promise<string>} the content written
 */
async function createFile(repoRoot, rel) {
  const abs = path.resolve(repoRoot, rel);
  const content = `// ${rel}\n${randomName(8, 40)}\n`;
  await fs.mkdir(path.dirname(abs), { recursive: true });
  await fs.writeFile(abs, content);
  return content;
}

/** Shuffle an array in place (Fisher–Yates). */
function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = randInt(i + 1);
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

test('Property 5: deleteTargets removes exactly the listed existing paths and nothing else', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('delete-targets-');
    try {
      const taken = new Set();

      // (a) Manifest paths that EXIST on disk and must be deleted.
      const existingManifestCount = randIntRange(1, 8);
      const existingManifest = [];
      for (let k = 0; k < existingManifestCount; k++) {
        const rel = uniqueRelPath(taken);
        await createFile(repoRoot, rel);
        existingManifest.push(rel);
      }

      // (b) Manifest paths that do NOT exist on disk — exercise ENOENT
      //     tolerance. These are listed but never created.
      const missingManifestCount = randIntRange(0, 5);
      const missingManifest = [];
      for (let k = 0; k < missingManifestCount; k++) {
        missingManifest.push(uniqueRelPath(taken));
      }

      // (c) "Other" files that are NOT in the manifest and must survive
      //     byte-identical (nothing outside the list may be removed).
      const otherCount = randIntRange(0, 8);
      const otherFiles = new Map(); // rel -> content
      for (let k = 0; k < otherCount; k++) {
        const rel = uniqueRelPath(taken);
        const content = await createFile(repoRoot, rel);
        otherFiles.set(rel, content);
      }

      // The manifest list, in randomized order.
      const manifestPaths = shuffle([...existingManifest, ...missingManifest]);

      const ctx =
        `iteration ${i}\n` +
        `existing=${JSON.stringify(existingManifest)}\n` +
        `missing=${JSON.stringify(missingManifest)}\n` +
        `other=${JSON.stringify([...otherFiles.keys()])}`;

      // --- Act ---
      const result = deleteTargets(repoRoot, manifestPaths);

      // --- Assert: result shape ---
      assert.ok(result && typeof result === 'object', `result is an object (${ctx})`);
      assert.ok(Array.isArray(result.deleted), `result.deleted is an array (${ctx})`);
      assert.ok(Array.isArray(result.skipped), `result.skipped is an array (${ctx})`);

      // deleted is exactly the set of existing manifest paths.
      assert.deepEqual(
        [...result.deleted].sort(),
        [...existingManifest].sort(),
        `deleted must equal the existing manifest paths (${ctx})`,
      );

      // skipped is exactly the set of non-existent manifest paths.
      assert.deepEqual(
        [...result.skipped].sort(),
        [...missingManifest].sort(),
        `skipped must equal the non-existent manifest paths (${ctx})`,
      );

      // --- Assert: every existing manifest path is now gone ---
      for (const rel of existingManifest) {
        const abs = path.resolve(repoRoot, rel);
        let gone = false;
        try {
          await fs.access(abs);
        } catch {
          gone = true;
        }
        assert.ok(gone, `deleted file must no longer exist: ${rel} (${ctx})`);
      }

      // --- Assert: nothing outside the list was removed; survivors are
      //     byte-identical ---
      for (const [rel, expectedContent] of otherFiles) {
        const abs = path.resolve(repoRoot, rel);
        const actual = await fs.readFile(abs, 'utf8');
        assert.equal(
          actual,
          expectedContent,
          `non-manifest file must survive byte-identical: ${rel} (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
