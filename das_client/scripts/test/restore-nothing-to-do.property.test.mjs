// restore-nothing-to-do.property.test.mjs
//
// End-to-end property test for restoreBase() nothing-to-do safety.
//
// Feature: flavor-code-switching, Property 15: Restore-base with nothing to
// restore is a safe no-op: when there is no readable (VALID) Flavor_Manifest AND
// no Base_Backup_Directory contents, restoreBase() reports "Nothing to restore",
// exits 0, and leaves every file in the repository byte-identical — nothing is
// created, deleted, or modified (every lib/ folder unchanged).
//
// Two sub-cases are exercised per the task:
//   (a) truly nothing — no manifest and no backup dir;
//   (b) a corrupt manifest present but still no backup dir. Per Req 11.5 the
//       guard fires when the manifest is NOT VALID *and* the backup dir has no
//       contents, so a CORRUPT (unreadable) manifest with no backup is still a
//       safe no-op.
//
// Validates: Requirements 11.5
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import crypto from 'node:crypto';
import path from 'node:path';

import { restoreBase, FLAVORS, MANIFEST_VERSION } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo, pathExists } from './helpers.mjs';

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

/** Random file content, incl. unicode, to exercise byte fidelity. */
function randomContent(tag = '') {
  const len = randIntRange(0, 48);
  let s = tag;
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/**
 * Build a random nested lib/ tree: POSIX relpath -> content. May be empty so we
 * also cover components with an empty lib/ folder.
 * @returns {Record<string, string>}
 */
function randomLibTree() {
  const fileCount = randInt(6); // 0..5
  const tree = {};
  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10 + 1) {
    attempts++;
    const depth = randInt(3); // 0..2 nested dirs
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
    segs.push(`${randomName(1, 8)}.dart`);
    const rel = segs.join('/');
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent('LIB::');
  }
  return tree;
}

/**
 * Produce a manifest payload that is NOT valid manifest data, so readManifest
 * classifies it CORRUPT. Mirrors the generators used by the first-run/corrupt
 * suite. The guard still fires because there is no backup dir.
 * @returns {string}
 */
function randomCorruptManifestRaw() {
  const kind = randInt(6);
  switch (kind) {
    case 0:
      // Non-JSON garbage.
      return randomName(1, 40) + '{not: json,,';
    case 1:
      // Valid JSON but not an object (array).
      return JSON.stringify([1, 2, 3]);
    case 2:
      // Valid JSON scalar.
      return JSON.stringify(randomName(1, 10));
    case 3:
      // Object with wrong version (e.g. a surviving v1 manifest).
      return JSON.stringify({ version: MANIFEST_VERSION + 1, flavor: pick(FLAVORS), files: [] });
    case 4:
      // Object with an invalid flavor.
      return JSON.stringify({ version: MANIFEST_VERSION, flavor: randomName(1, 6), files: [] });
    default:
      // Object with files that is not an array of entry objects.
      return JSON.stringify({ version: MANIFEST_VERSION, flavor: pick(FLAVORS), files: [1, 2, 3] });
  }
}

/**
 * Walk the whole repo tree and return a snapshot mapping every repo-relative
 * POSIX path -> sha256 of its bytes. Directories are not included; file content
 * (and the exact set of files) fully determines equality for a no-op check.
 * @param {string} root absolute repo root
 * @returns {Promise<Map<string,string>>}
 */
async function snapshotTree(root) {
  const snapshot = new Map();

  async function walk(absDir, relDir) {
    const dirents = await fsp.readdir(absDir, { withFileTypes: true });
    for (const dirent of dirents) {
      const abs = path.join(absDir, dirent.name);
      const rel = relDir === '' ? dirent.name : `${relDir}/${dirent.name}`;
      if (dirent.isDirectory()) {
        await walk(abs, rel);
      } else if (dirent.isFile()) {
        const bytes = await fsp.readFile(abs);
        snapshot.set(rel, crypto.createHash('sha256').update(bytes).digest('hex'));
      }
    }
  }

  await walk(root, '');
  return snapshot;
}

test('Property 15: restore-base with nothing to restore is a safe no-op', async () => {
  // Silence restoreBase()'s console output but capture console.log so we can
  // assert "Nothing to restore" was reported to stdout.
  const origLog = console.log;
  const origError = console.error;

  try {
    for (let i = 0; i < ITERATIONS; i++) {
      const repoRoot = await makeTempDir('flavor-restore-noop-prop-');
      try {
        // Build a random repo with components + lib trees, but NO manifest and
        // NO .flavor-base-backup/ directory (no prior switch).
        const componentCount = randIntRange(1, 3);
        const components = [];
        for (let c = 0; c < componentCount; c++) {
          components.push({
            name: `comp_${randomName(2, 8)}_${c}`,
            lib: randomLibTree(),
          });
        }

        // Sub-case (a) truly nothing; (b) corrupt manifest present, no backup.
        const corruptManifest = Math.random() < 0.5;
        const repoSpec = { components };
        if (corruptManifest) {
          repoSpec.manifestRaw = randomCorruptManifestRaw();
        }
        await buildRepo(repoRoot, repoSpec);

        const ctx = `iter=${i} comps=${componentCount} corruptManifest=${corruptManifest}`;

        // Guard the fixture invariant: no backup dir exists (no prior switch).
        assert.equal(
          await pathExists(path.join(repoRoot, '.flavor-base-backup')),
          false,
          `fixture must have no backup dir (${ctx})`,
        );

        // Full repo snapshot BEFORE the restore.
        const before = await snapshotTree(repoRoot);

        // Capture stdout for the "Nothing to restore" assertion; still silence stderr.
        const logged = [];
        console.log = (...parts) => {
          logged.push(parts.join(' '));
        };
        console.error = () => {};

        const code = restoreBase(repoRoot);

        console.log = origLog;
        console.error = origError;

        // Safe no-op: exit 0.
        assert.equal(code, 0, `restoreBase must exit 0 when nothing to restore (${ctx})`);

        // "Nothing to restore" was reported to stdout.
        assert.ok(
          logged.some((line) => line.includes('Nothing to restore')),
          `restoreBase must report "Nothing to restore" (${ctx}); got: ${JSON.stringify(logged)}`,
        );

        // Full repo tree AFTER equals BEFORE — byte-identical, nothing
        // created/deleted/modified (every lib/ folder unchanged).
        const after = await snapshotTree(repoRoot);
        assert.deepEqual(
          [...after.keys()].sort(),
          [...before.keys()].sort(),
          `no file may be created or deleted (${ctx})`,
        );
        for (const [rel, hash] of before.entries()) {
          assert.equal(
            after.get(rel),
            hash,
            `file content must be byte-identical: ${rel} (${ctx})`,
          );
        }

        // And explicitly: no backup dir was created by the no-op.
        assert.equal(
          fs.existsSync(path.join(repoRoot, '.flavor-base-backup')),
          false,
          `no backup dir may be created by the no-op (${ctx})`,
        );
      } finally {
        console.log = origLog;
        console.error = origError;
        await removeTempDir(repoRoot);
      }
    }
  } finally {
    console.log = origLog;
    console.error = origError;
  }
});
