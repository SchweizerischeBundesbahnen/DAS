// save-to-flavor-invalid.property.test.mjs
//
// Property test for saveToFlavor invalid-input non-mutation.
//
// Feature: flavor-code-switching, Property 17: Copy-to-flavor rejects invalid
// input without mutation: for any random repo, invoking saveToFlavor with an
// invalid flavor, a missing source file, or a non-lib/ source path returns a
// non-zero exit code and leaves the ENTIRE repo tree byte-identical — nothing is
// created (in particular not in any flavor folder), overwritten, or deleted.
//
// Validates: Requirements 12.5, 12.6, 12.7
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveToFlavor, FLAVORS } from '../switch-flavor.mjs';
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
 * Take a FULL repo-tree snapshot: a map of every regular file's repo-relative
 * POSIX path → sha256 of its bytes. Walks the whole tree recursively.
 * @param {string} repoRoot
 * @returns {Promise<Map<string, string>>}
 */
async function snapshotRepoTree(repoRoot) {
  const snapshot = new Map();

  async function walk(absDir) {
    const dirents = await fsp.readdir(absDir, { withFileTypes: true });
    for (const dirent of dirents) {
      const abs = path.join(absDir, dirent.name);
      if (dirent.isDirectory()) {
        await walk(abs);
      } else if (dirent.isFile()) {
        const bytes = await fsp.readFile(abs);
        const rel = path.relative(repoRoot, abs).split(path.sep).join('/');
        const hash = crypto.createHash('sha256').update(bytes).digest('hex');
        snapshot.set(rel, hash);
      }
    }
  }

  await walk(repoRoot);
  return snapshot;
}

/** Assert two repo-tree snapshots are byte-identical (same paths, same hashes). */
function assertSnapshotsEqual(before, after, ctx) {
  const beforeKeys = [...before.keys()].sort();
  const afterKeys = [...after.keys()].sort();
  assert.deepEqual(
    afterKeys,
    beforeKeys,
    `repo tree must have the same set of files before and after (${ctx})`,
  );
  for (const key of beforeKeys) {
    assert.equal(
      after.get(key),
      before.get(key),
      `file '${key}' must be byte-identical before and after (${ctx})`,
    );
  }
}

test('Property 17: saveToFlavor rejects invalid input (invalid flavor / missing source / non-lib path) without mutating the repo', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-to-flavor-invalid-prop-');
    try {
      // Build a random repo with a plausible existing lib/ source file.
      const componentName = randomName(3, 10);
      const rest = randomRest();
      const sourceContent = randomContent();
      const sourceRel = `${componentName}/lib/${rest}`;

      await buildRepo(repoRoot, {
        components: [{ name: componentName, lib: { [rest]: sourceContent } }],
      });

      // FULL repo-tree snapshot BEFORE the invalid invocation.
      const before = await snapshotRepoTree(repoRoot);

      // Pick ONE of the three invalid-input classes at random.
      const invalidClass = pick(['invalid_flavor', 'missing_source', 'non_lib_path']);
      let flavor;
      let file;

      if (invalidClass === 'invalid_flavor') {
        // (a) A random non-FLAVOR string as the flavor, with an otherwise-plausible
        //     existing lib/ source file (Req 12.5).
        do {
          flavor = randomName(1, 8);
        } while (FLAVORS.includes(flavor));
        file = sourceRel;
      } else if (invalidClass === 'missing_source') {
        // (b) Valid flavor + a <comp>/lib/<rest> path that does NOT exist (Req 12.6).
        flavor = pick(FLAVORS);
        let missingRest;
        do {
          missingRest = randomRest();
        } while (missingRest === rest);
        file = `${componentName}/lib/${missingRest}`;
      } else {
        // (c) Valid flavor + a path that is NOT <component>/lib/<rest> (Req 12.7).
        flavor = pick(FLAVORS);
        const shapeKind = randInt(2);
        if (shapeKind === 0) {
          // <comp>/foo.dart — no lib/ segment after the component.
          file = `${componentName}/${randomName(1, 8)}.dart`;
        } else {
          // lib/foo.dart — no component segment before lib/.
          file = `lib/${randomName(1, 8)}.dart`;
        }
      }

      const ctx = `iter=${i} class='${invalidClass}' flavor='${flavor}' file='${file}'`;

      // Invoke with console silenced; it must reject with a non-zero exit code.
      const code = withSilencedConsole(() => saveToFlavor(repoRoot, flavor, file));
      assert.equal(code, 1, `saveToFlavor must return 1 for invalid input (${ctx})`);

      // FULL repo-tree snapshot AFTER must equal BEFORE: nothing created
      // (in particular no file in any flavor folder), overwritten, or deleted.
      const after = await snapshotRepoTree(repoRoot);
      assertSnapshotsEqual(before, after, ctx);

      // Belt-and-suspenders: the derived flavor destination for a valid-shape
      // path must not have been created for the invalid_flavor / missing_source
      // classes (which keep the <comp>/lib/<rest> shape).
      if (invalidClass !== 'non_lib_path') {
        const destAbs = path.join(repoRoot, componentName, flavor, rest);
        assert.ok(
          !fs.existsSync(destAbs),
          `no file must have been created at the flavor destination (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
