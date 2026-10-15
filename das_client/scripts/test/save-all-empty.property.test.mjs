// save-all-empty.property.test.mjs
//
// Property test for the save-all empty-changeset no-op.
//
// Feature: flavor-code-switching, Property 21: Save-all with no changed lib/ or
// test/ files is a safe no-op: when the (faked) Git state yields NO changed
// source files — whether because `git status --porcelain -z` reports nothing at
// all, or because it reports only non-source changed paths that the lib/+test/
// filter drops — `saveAllToFlavor` copies and deletes nothing anywhere in the
// repo tree, reports "No changed lib/ or test/ files to save" to stdout, and
// returns exit code 0.
//
// Validates: Requirements 13.8
//
// Pure Node, zero third-party dependencies. The Git invocations are faked via an
// injected `spawn`, so the test is hermetic (no real Git required). It does NOT
// modify scripts/switch-flavor.mjs.
//
// Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

import { saveAllToFlavor, FLAVORS } from '../switch-flavor.mjs';
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

/** Random file content. */
function randomContent() {
  const len = randIntRange(0, 48);
  let s = '';
  const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Build a random nested relative POSIX path ending in a .dart file. */
function randomRest() {
  const depth = randInt(3); // 0..2 intermediate directories
  const segs = [];
  for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
  segs.push(`${randomName(1, 8)}.dart`);
  return segs.join('/');
}

/** Capture console.log/console.error output while running `fn`. */
function captureConsole(fn) {
  const origLog = console.log;
  const origError = console.error;
  const logs = [];
  const errs = [];
  console.log = (...args) => logs.push(args.join(' '));
  console.error = (...args) => errs.push(args.join(' '));
  try {
    const result = fn();
    return { result, logs, errs };
  } finally {
    console.log = origLog;
    console.error = origError;
  }
}

/**
 * Take a full repo-tree snapshot: a map from repo-relative POSIX path to the
 * sha256 of the file's bytes. Captures EVERY file under `repoRoot` so the test
 * can assert nothing was copied, deleted, or modified anywhere.
 * @param {string} repoRoot
 * @returns {Promise<Map<string,string>>}
 */
async function snapshotTree(repoRoot) {
  const snapshot = new Map();
  async function walk(dir) {
    const dirents = await fsp.readdir(dir, { withFileTypes: true });
    for (const dirent of dirents) {
      const abs = path.join(dir, dirent.name);
      if (dirent.isDirectory()) {
        await walk(abs);
      } else if (dirent.isFile()) {
        const bytes = await fsp.readFile(abs);
        const rel = path.relative(repoRoot, abs).split(path.sep).join('/');
        snapshot.set(rel, crypto.createHash('sha256').update(bytes).digest('hex'));
      }
    }
  }
  await walk(repoRoot);
  return snapshot;
}

/** Assert two tree snapshots are exactly equal (same paths, same hashes). */
function assertSnapshotsEqual(before, after, ctx) {
  assert.equal(
    after.size,
    before.size,
    `repo tree file count must be unchanged (before=${before.size} after=${after.size}) (${ctx})`,
  );
  for (const [rel, hash] of before) {
    assert.ok(after.has(rel), `file '${rel}' must still exist after save-all (${ctx})`);
    assert.equal(after.get(rel), hash, `file '${rel}' must be byte-identical after save-all (${ctx})`);
  }
  for (const rel of after.keys()) {
    assert.ok(before.has(rel), `no new file '${rel}' may be created by save-all (${ctx})`);
  }
}

/**
 * Build a fake `spawn` matching gitChangedSourceFiles' two git calls:
 *   - `git -C <repoRoot> rev-parse --show-toplevel` → { status: 0, stdout: repoRoot+'\n' }
 *   - `git -C <repoRoot> status --porcelain -z`     → { status: 0, stdout: statusOut }
 * @param {string} repoRoot
 * @param {string} statusOut porcelain -z output (NUL-separated)
 * @returns {Function}
 */
function makeFakeSpawn(repoRoot, statusOut) {
  return (cmd, args) => {
    assert.equal(cmd, 'git', 'fake spawn should only be asked to run git');
    const sub = args[2]; // args: ['-C', repoRoot, '<subcommand>', ...]
    if (sub === 'rev-parse') {
      return { status: 0, stdout: `${repoRoot}\n` };
    }
    if (sub === 'status') {
      return { status: 0, stdout: statusOut };
    }
    throw new Error(`unexpected git subcommand in fake spawn: ${sub}`);
  };
}

test('Feature: flavor-code-switching, Property 21: Save-all with no changed lib/ or test/ files is a safe no-op', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-all-empty-prop-');
    try {
      const flavor = pick(FLAVORS);

      // Build a repo with random components, lib/ files, and (optionally) some
      // pre-existing flavor-folder files, so the snapshot has real content to
      // guard against spurious copies/deletes.
      const componentCount = randIntRange(1, 3);
      const components = [];
      for (let c = 0; c < componentCount; c++) {
        const name = randomName(3, 10);
        const lib = {};
        const libFileCount = randIntRange(1, 4);
        for (let f = 0; f < libFileCount; f++) {
          lib[randomRest()] = randomContent();
        }
        const spec = { name, lib };
        // ~half the components also carry an existing flavor folder, which must
        // remain untouched by the no-op.
        if (Math.random() < 0.5) {
          const flavorFiles = {};
          const flavorFileCount = randIntRange(1, 3);
          for (let f = 0; f < flavorFileCount; f++) {
            flavorFiles[randomRest()] = randomContent();
          }
          spec.flavors = { [pick(FLAVORS)]: flavorFiles };
        }
        components.push(spec);
      }
      await buildRepo(repoRoot, { components });

      // Choose a sub-case for the faked `git status --porcelain -z` output that
      // yields NO changed source files:
      //   (a) completely empty output ('')
      //   (b) only NON-source changed paths, which the lib/+test/ filter drops to empty.
      let statusOut;
      let subcase;
      if (Math.random() < 0.5) {
        subcase = 'empty';
        statusOut = '';
      } else {
        subcase = 'non-source';
        const comp = pick(components).name;
        // Porcelain -z records are NUL-terminated: 'XY PATH\0'. None of these
        // qualify as <component>/lib/<rest> or <component>/test/<rest>, so
        // deriveFlavorDest drops them all. (A file directly under the component,
        // the root pubspec, a README, and a doc are all outside a source root.)
        const records = [
          `?? ${comp}/${randomName(1, 6)}.dart`,
          ` M README.md`,
          `?? ${comp}/pubspec.yaml`,
          `A  docs/${randomName(1, 6)}.md`,
        ];
        statusOut = records.map((r) => `${r}\0`).join('');
      }

      const ctx = `iter=${i} flavor='${flavor}' subcase=${subcase} components=${componentCount}`;

      // Snapshot the FULL repo tree before.
      const before = await snapshotTree(repoRoot);

      const fakeSpawn = makeFakeSpawn(repoRoot, statusOut);

      const { result: code, logs } = captureConsole(() =>
        saveAllToFlavor(repoRoot, flavor, { spawn: fakeSpawn }),
      );

      // Exit code 0 (no-op is a success).
      assert.equal(code, 0, `saveAllToFlavor must return 0 on an empty changeset (${ctx})`);

      // The "No changed lib/ or test/ files to save" report was emitted to stdout.
      const reported = logs.some((line) => line.includes('No changed lib/ or test/ files to save'));
      assert.ok(
        reported,
        `stdout must report "No changed lib/ or test/ files to save" (${ctx}); got: ${JSON.stringify(logs)}`,
      );

      // The full repo tree is byte-identical: nothing copied or deleted anywhere.
      const after = await snapshotTree(repoRoot);
      assertSnapshotsEqual(before, after, ctx);
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
