// save-all-delete.property.test.mjs
//
// Property test for saveAllToFlavor deletion behavior.
//
// Feature: flavor-code-switching, Property 20: Save-all deletes a flavor file
// iff the deleted lib/ path has one: for each lib/ path Git reports as deleted
// (listed in porcelain status but absent on disk), saveAllToFlavor removes the
// derived flavor destination <component>/<flavor>/<rest> when that destination
// exists, and leaves the Flavor_Folder unchanged (destination still absent) when
// it does not. Processing of the remaining deleted paths still completes, and no
// unrelated files are created.
//
// Validates: Requirements 13.4, 13.5
//
// The Git working-tree state is faked via an injected `spawn`, so no real Git is
// required: `git -C <repoRoot> rev-parse --show-toplevel` returns the repoRoot,
// and `git -C <repoRoot> status --porcelain -z` returns a NUL-separated porcelain
// stream listing the deleted paths. gitChangedLibFiles classifies each path as
// `deleted` purely because it is listed but does NOT exist under repoRoot on disk.
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

import { saveAllToFlavor, FLAVORS } from '../switch-flavor.mjs';
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
function randomName(minLen = 1, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content for the pre-existing flavor destinations. */
function randomContent() {
  const len = randIntRange(1, 48);
  let s = '';
  const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Build a random nested relative POSIX path for a lib/ file (non-empty rest). */
function randomRest() {
  const depth = randInt(3); // 0..2 intermediate directories
  const segs = [];
  for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
  segs.push(`${randomName(1, 8)}.dart`);
  return segs.join('/');
}

/** Silence console.log/console.error for the duration of `fn`. */
function withSilencedConsole(fn) {
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};
  try {
    return fn();
  } finally {
    console.log = origLog;
    console.error = origError;
  }
}

/**
 * Build a fake `spawn` that answers the two git calls gitChangedLibFiles makes:
 *   - `rev-parse --show-toplevel` → the repoRoot (so top-level === repoRoot)
 *   - `status --porcelain -z`     → the given NUL-separated porcelain stream
 * Any other call returns a non-zero status so the test fails loudly if the
 * contract drifts.
 *
 * @param {string} repoRoot
 * @param {string} porcelainZ  the `-z` porcelain stdout
 */
function makeFakeSpawn(repoRoot, porcelainZ) {
  return (cmd, args) => {
    if (cmd === 'git' && args.includes('rev-parse') && args.includes('--show-toplevel')) {
      return { status: 0, stdout: `${repoRoot}\n` };
    }
    if (cmd === 'git' && args.includes('status') && args.includes('--porcelain')) {
      return { status: 0, stdout: porcelainZ };
    }
    return { status: 1, stdout: '' };
  };
}

/**
 * Recursively collect every file path (repo-relative POSIX) under `dir`.
 * @param {string} root absolute repo root
 * @param {string} dir  absolute directory to walk
 * @returns {string[]}
 */
function listFiles(root, dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const abs = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...listFiles(root, abs));
    } else if (entry.isFile()) {
      out.push(path.relative(root, abs).split(path.sep).join('/'));
    }
  }
  return out;
}

test("Feature: flavor-code-switching, Property 20: Save-all deletes a flavor file iff the deleted lib/ path has one", async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-all-delete-prop-');
    try {
      const flavor = pick(FLAVORS);
      const componentName = randomName(3, 10);

      // Generate a set of DELETED lib paths <component>/lib/<rest>. They are NOT
      // created under lib/ on disk, so gitChangedLibFiles classifies them deleted.
      const count = randIntRange(1, 6);
      const rests = new Set();
      while (rests.size < count) rests.add(randomRest());
      const deletedRests = [...rests];

      // For an arbitrary subset, PRE-CREATE the flavor destination on disk; the
      // complement have NO flavor file at all.
      const flavorFiles = {}; // rest -> content, for the subset with a dest
      for (const rest of deletedRests) {
        if (Math.random() < 0.5) flavorFiles[rest] = randomContent();
      }

      // Build the repo. The component has a lib/ folder (so it is discoverable as
      // a component) but none of the deleted rests exist under lib/. The subset
      // with a flavor destination is seeded via the flavors spec.
      await buildRepo(repoRoot, {
        components: [
          {
            name: componentName,
            lib: { 'keep.dart': 'base' }, // an unrelated base file that must survive
            flavors: Object.keys(flavorFiles).length
              ? { [flavor]: flavorFiles }
              : undefined,
          },
        ],
      });

      // Record which flavor destinations existed before, and the complete file
      // set before, to detect accidental creation of unrelated files.
      const destExistedBefore = new Map(); // rest -> boolean
      const destContentBefore = new Map(); // rest -> content (when existed)
      for (const rest of deletedRests) {
        const destAbs = path.join(repoRoot, componentName, `.${flavor}`, rest);
        const existed = fs.existsSync(destAbs);
        destExistedBefore.set(rest, existed);
        if (existed) destContentBefore.set(rest, fs.readFileSync(destAbs, 'utf8'));
      }
      const filesBefore = new Set(listFiles(repoRoot, repoRoot));

      // Build the fake porcelain -z stream: one `XY<space>PATH` record per deleted
      // path, NUL-terminated. Record shape is `XY PATH` (status = first 2 chars,
      // path begins at index 3), matching gitChangedLibFiles' parsing. Alternate
      // between index-deleted (`D `) and worktree-deleted (` D`) status codes.
      const records = deletedRests.map((rest, idx) => {
        const status = idx % 2 === 0 ? ' D' : 'D ';
        return `${status} ${componentName}/lib/${rest}`;
      });
      const porcelainZ = records.map((r) => `${r}\0`).join('');

      const spawn = makeFakeSpawn(repoRoot, porcelainZ);
      const ctx = `iter=${i} flavor='${flavor}' component='${componentName}' deleted=${deletedRests.length}`;

      const code = withSilencedConsole(() => saveAllToFlavor(repoRoot, flavor, { spawn }));
      assert.equal(code, 0, `saveAllToFlavor must return 0 (${ctx})`);

      // Per deleted path: dest existed → now removed; dest absent → still absent.
      for (const rest of deletedRests) {
        const destAbs = path.join(repoRoot, componentName, `.${flavor}`, rest);
        const destRel = `${componentName}/.${flavor}/${rest}`;
        if (destExistedBefore.get(rest)) {
          assert.ok(
            !fs.existsSync(destAbs),
            `deleted path with a flavor file must have it removed: ${destRel} (${ctx})`,
          );
        } else {
          assert.ok(
            !fs.existsSync(destAbs),
            `deleted path with no flavor file must stay absent: ${destRel} (${ctx})`,
          );
        }
      }

      // The unrelated base file under lib/ must be untouched.
      const keepAbs = path.join(repoRoot, componentName, 'lib', 'keep.dart');
      assert.ok(fs.existsSync(keepAbs), `unrelated lib/ base file must survive (${ctx})`);
      assert.equal(fs.readFileSync(keepAbs, 'utf8'), 'base', `unrelated base content unchanged (${ctx})`);

      // No unrelated files were created: the file set after must be a SUBSET of
      // the file set before (only removals of the pre-existing flavor dests are
      // allowed, never additions).
      const filesAfter = new Set(listFiles(repoRoot, repoRoot));
      for (const f of filesAfter) {
        assert.ok(filesBefore.has(f), `no unrelated file may be created: '${f}' appeared (${ctx})`);
      }

      // Exactly the pre-existing flavor destinations were removed; nothing else.
      const removedExpected = new Set(
        deletedRests
          .filter((rest) => destExistedBefore.get(rest))
          .map((rest) => `${componentName}/.${flavor}/${rest}`),
      );
      for (const f of filesBefore) {
        if (!filesAfter.has(f)) {
          assert.ok(
            removedExpected.has(f),
            `only pre-existing deleted-path flavor files may be removed; '${f}' was removed unexpectedly (${ctx})`,
          );
        }
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
