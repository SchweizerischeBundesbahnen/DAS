// restore-roundtrip.property.test.mjs
//
// Property test for the switch→restore-base round-trip.
//
// Feature: flavor-code-switching, Property 14: Switch-then-restore round-trips
// lib/ to the base: switching to a flavor that overwrites some base files and
// adds others, then running restore-base, returns lib/ to its original (base)
// state — every overwritten file restored to its original content, every new
// file removed, every unrelated file untouched — and clears the switch
// bookkeeping (manifest removed, Base_Backup_Directory removed).
//
// Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.6
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

import {
  main,
  restoreBase,
  FLAVORS,
  BASE_BACKUP_DIRNAME,
  MANIFEST_FILENAME,
} from '../switch-flavor.mjs';
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

/** Produce a random lowercase identifier within the given length range. */
function randomName(minLen = 3, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content: empty, ascii-ish text, or unicode bytes. */
function randomContent() {
  const kind = randInt(3);
  if (kind === 0) return '';
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

/** Content guaranteed to differ from `other` (so an overwrite is observable). */
function differentContent(other) {
  let c = randomContent();
  while (c === other) c = `${randomContent()}x`;
  return c;
}

/**
 * Produce `count` distinct nested relative POSIX file paths, keeping global
 * uniqueness via the shared `used` set.
 * @param {number} count
 * @param {Set<string>} used
 * @returns {string[]}
 */
function distinctRelPaths(count, used) {
  const out = [];
  let attempts = 0;
  while (out.length < count && attempts < count * 40) {
    attempts++;
    const depth = randInt(3); // 0..2 nested dirs
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 5));
    segs.push(`${randomName(1, 8)}.dart`);
    const rel = segs.join('/');
    if (used.has(rel)) continue;
    used.add(rel);
    out.push(rel);
  }
  return out;
}

/** SHA-256 of a file's bytes, or undefined if the file is absent. */
function sha256OrUndefined(absPath) {
  try {
    const buf = fs.readFileSync(absPath);
    return crypto.createHash('sha256').update(buf).digest('hex');
  } catch (err) {
    if (err && err.code === 'ENOENT') return undefined;
    throw err;
  }
}

/**
 * Snapshot the full lib/ state across the repo for the given set of
 * repo-relative POSIX lib paths. Returns a map path -> sha256, OMITTING paths
 * that do not currently exist on disk (so "new file now absent" shows up as a
 * missing key, matching the before-snapshot where it was also absent).
 * @param {string} repoRoot
 * @param {Set<string>} libPaths repo-relative POSIX lib paths to probe
 * @returns {Record<string,string>}
 */
function snapshotLib(repoRoot, libPaths) {
  const snap = {};
  for (const rel of libPaths) {
    const hash = sha256OrUndefined(path.join(repoRoot, rel));
    if (hash !== undefined) snap[rel] = hash;
  }
  return snap;
}

/** Silence console output while exercising the real orchestration. */
function withSilencedConsole(fn) {
  const log = console.log;
  const error = console.error;
  console.log = () => {};
  console.error = () => {};
  try {
    return fn();
  } finally {
    console.log = log;
    console.error = error;
  }
}

test('Property 14: switch then restore-base round-trips lib/ to the original base', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-restore-prop-');
    try {
      const flavor = pick(FLAVORS);

      // In a fraction of iterations, delete one Base_Backup_File after the
      // switch but before restore, to exercise the missing-backup tolerance
      // (Req 11.6).
      const dropOneBackup = Math.random() < 0.25;

      const componentCount = randIntRange(1, 3);
      const components = [];
      const usedRelPaths = new Set(); // rel paths unique across the whole repo

      // The full set of repo-relative lib paths we care about (overwrites, new
      // files, and unrelated pre-existing files). Used to snapshot the SAME path
      // set before and after so the comparison is apples-to-apples.
      const trackedLibPaths = new Set();
      // repo-relative lib paths that the flavor OVERWRITES (base file pre-exists).
      const overwriteLibPaths = [];
      // repo-relative lib paths that the flavor adds as NEW files (no base).
      const newLibPaths = [];

      for (let c = 0; c < componentCount; c++) {
        const name = `comp_${i}_${c}_${randomName(2, 5)}`;
        const lib = {};
        const flavorFiles = {};

        // Overwrites: base file at rel + DIFFERENT-content flavor file at rel.
        const overwriteCount = randIntRange(0, 3);
        for (const rel of distinctRelPaths(overwriteCount, usedRelPaths)) {
          const baseContent = randomContent();
          lib[rel] = baseContent;
          flavorFiles[rel] = differentContent(baseContent);
          const libRel = `${name}/lib/${rel}`;
          trackedLibPaths.add(libRel);
          overwriteLibPaths.push(libRel);
        }

        // New files: flavor file at rel with NO base file at rel.
        const newCount = randIntRange(0, 3);
        for (const rel of distinctRelPaths(newCount, usedRelPaths)) {
          flavorFiles[rel] = randomContent();
          const libRel = `${name}/lib/${rel}`;
          trackedLibPaths.add(libRel);
          newLibPaths.push(libRel);
        }

        // Unrelated pre-existing lib files the flavor never touches.
        const unrelatedCount = randIntRange(0, 3);
        for (const rel of distinctRelPaths(unrelatedCount, usedRelPaths)) {
          lib[rel] = randomContent();
          trackedLibPaths.add(`${name}/lib/${rel}`);
        }

        const spec = { name };
        if (Object.keys(lib).length > 0) spec.lib = lib;
        if (Object.keys(flavorFiles).length > 0) spec.flavors = { [flavor]: flavorFiles };
        components.push(spec);
      }

      // Guarantee a non-empty copy plan (otherwise the switch exits 1). Ensure at
      // least one overwrite AND at least one new file somewhere so the property
      // is non-vacuous for both branches.
      const ensureFlavorTarget = (makeOverwrite) => {
        const comp = components[0];
        comp.flavors = comp.flavors ?? {};
        comp.flavors[flavor] = comp.flavors[flavor] ?? {};
        const [rel] = distinctRelPaths(1, usedRelPaths);
        const libRel = `${comp.name}/lib/${rel}`;
        if (makeOverwrite) {
          const baseContent = randomContent();
          comp.lib = comp.lib ?? {};
          comp.lib[rel] = baseContent;
          comp.flavors[flavor][rel] = differentContent(baseContent);
          overwriteLibPaths.push(libRel);
        } else {
          comp.flavors[flavor][rel] = randomContent();
          newLibPaths.push(libRel);
        }
        trackedLibPaths.add(libRel);
      };
      if (overwriteLibPaths.length === 0) ensureFlavorTarget(true);
      if (newLibPaths.length === 0) ensureFlavorTarget(false);

      await buildRepo(repoRoot, { components });

      const ctx =
        `iter=${i} flavor='${flavor}' |overwrite|=${overwriteLibPaths.length} ` +
        `|new|=${newLibPaths.length} dropBackup=${dropOneBackup}`;

      // 1. Snapshot the ORIGINAL base lib/ state BEFORE the switch.
      const baseSnapshot = snapshotLib(repoRoot, trackedLibPaths);

      // Sanity: overwrite targets and unrelated files exist in the base; new
      // files do not (they are added by the switch).
      for (const libRel of overwriteLibPaths) {
        assert.ok(
          baseSnapshot[libRel] !== undefined,
          `overwrite target must exist in base: ${libRel} (${ctx})`,
        );
      }
      for (const libRel of newLibPaths) {
        assert.ok(
          baseSnapshot[libRel] === undefined,
          `new target must be absent in base: ${libRel} (${ctx})`,
        );
      }

      // 2. Switch to the flavor.
      const switchCode = withSilencedConsole(() =>
        main(['node', 'switch-flavor.mjs', flavor], { repoRoot }),
      );
      assert.equal(switchCode, 0, `switch must return 0 (${ctx})`);

      // Overwritten lib files now differ from the base (the switch changed them);
      // new files now exist. (Guards against a vacuous round-trip.)
      for (const libRel of overwriteLibPaths) {
        const now = sha256OrUndefined(path.join(repoRoot, libRel));
        assert.ok(
          now !== undefined && now !== baseSnapshot[libRel],
          `overwrite target must have changed after switch: ${libRel} (${ctx})`,
        );
      }

      // Missing-backup tolerance (Req 11.6): optionally delete one backup file
      // of an overwritten path before restoring. restoreBase must still return 0
      // and still clean up; the dropped path may remain as flavor content (it
      // cannot be restored) — that one path is excluded from the exact-match
      // assertion below but we still assert the function tolerated it.
      let droppedLibRel;
      if (dropOneBackup && overwriteLibPaths.length > 0) {
        droppedLibRel = pick(overwriteLibPaths);
        const backupAbs = path.join(repoRoot, BASE_BACKUP_DIRNAME, droppedLibRel);
        // The backup must exist for an overwritten path; delete it.
        assert.ok(
          fs.existsSync(backupAbs),
          `backup must exist for overwritten path before drop: ${droppedLibRel} (${ctx})`,
        );
        fs.rmSync(backupAbs, { force: true });
      }

      // 3. Restore base.
      const restoreCode = withSilencedConsole(() => restoreBase(repoRoot));
      assert.equal(restoreCode, 0, `restoreBase must return 0 (${ctx})`);

      // 4a. lib/ equals the ORIGINAL base snapshot exactly — except for a dropped
      //     backup path (Req 11.6), which cannot be restored and is excluded.
      const afterSnapshot = snapshotLib(repoRoot, trackedLibPaths);

      const expected = { ...baseSnapshot };
      const actual = { ...afterSnapshot };
      if (droppedLibRel !== undefined) {
        delete expected[droppedLibRel];
        delete actual[droppedLibRel];
      }
      assert.deepEqual(
        actual,
        expected,
        `lib/ must round-trip to the original base after restore (${ctx})`,
      );

      // Explicitly: every NEW file is gone, every unrelated file untouched,
      // every (non-dropped) overwritten file restored. (deepEqual above covers
      // this; these assertions localize failures.)
      for (const libRel of newLibPaths) {
        assert.ok(
          !fs.existsSync(path.join(repoRoot, libRel)),
          `new file must be removed by restore: ${libRel} (${ctx})`,
        );
      }
      for (const libRel of overwriteLibPaths) {
        if (libRel === droppedLibRel) continue;
        assert.equal(
          sha256OrUndefined(path.join(repoRoot, libRel)),
          baseSnapshot[libRel],
          `overwritten file must be restored to base content: ${libRel} (${ctx})`,
        );
      }

      // 4b. Manifest cleared (Req 11.3).
      assert.ok(
        !fs.existsSync(path.join(repoRoot, MANIFEST_FILENAME)),
        `manifest must be removed after restore (${ctx})`,
      );

      // 4c. Base_Backup_Directory removed / empty (Req 11.3).
      const backupDirAbs = path.join(repoRoot, BASE_BACKUP_DIRNAME);
      if (fs.existsSync(backupDirAbs)) {
        assert.equal(
          fs.readdirSync(backupDirAbs).length,
          0,
          `base-backup dir must be empty after restore (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
