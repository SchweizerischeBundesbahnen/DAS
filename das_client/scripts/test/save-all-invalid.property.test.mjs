// save-all-invalid.property.test.mjs
//
// Property test for save-all invalid-input non-mutation.
//
// Feature: flavor-code-switching, Property 22: Save-all rejects invalid input
// without mutation: for any random repo, exercising ONE invalid save-all case —
// an invalid flavor passed to saveAllToFlavor, an unavailable / non-repo Git
// state, or a parse-level rejection (`--all` without `--save-to-flavor`, or
// `--all` + `--restore-base`) — yields a non-zero outcome and leaves the ENTIRE
// repo tree byte-identical: nothing is created (in particular not in any flavor
// folder), overwritten, or deleted.
//
// Validates: Requirements 13.6, 13.7, 13.9
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveAllToFlavor, parseCliArgs, FLAVORS } from '../switch-flavor.mjs';
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
 * A fake `spawn` that would SUCCEED if reached: `rev-parse` reports the repo
 * root as the Git top-level, `status` reports a clean working tree. Used for the
 * invalid-flavor case to prove the rejection happens BEFORE any git/copy I/O
 * (so even a healthy git would not cause mutation).
 * @param {string} repoRoot
 */
function makeOkFakeSpawn(repoRoot) {
  return function okFakeSpawn(_cmd, args) {
    if (args.includes('rev-parse')) {
      return { status: 0, stdout: `${repoRoot}\n` };
    }
    // `git status --porcelain -z` → empty (clean tree).
    return { status: 0, stdout: '' };
  };
}

/**
 * A fake `spawn` simulating git being unavailable / repoRoot not being a repo.
 * Randomly chooses between a spawn error (git missing) and a non-zero exit
 * (rev-parse fails because it is not a repository).
 */
function makeFailingSpawn() {
  const mode = randInt(2);
  return function failingSpawn(_cmd, args) {
    if (mode === 0) {
      // git binary missing → spawn error with ENOENT.
      return { error: Object.assign(new Error('spawn git ENOENT'), { code: 'ENOENT' }) };
    }
    // Not a repository → rev-parse (and status) exit non-zero.
    if (args.includes('rev-parse')) {
      return { status: 128, stdout: '' };
    }
    return { status: 128, stdout: '' };
  };
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

test('Feature: flavor-code-switching, Property 22: Save-all rejects invalid input without mutation', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-all-invalid-prop-');
    try {
      // Build a random repo with a plausible existing lib/ source file.
      const componentName = randomName(3, 10);
      const rest = randomRest();
      const sourceContent = randomContent();

      await buildRepo(repoRoot, {
        components: [{ name: componentName, lib: { [rest]: sourceContent } }],
      });

      // FULL repo-tree snapshot BEFORE the invalid invocation.
      const before = await snapshotRepoTree(repoRoot);

      // Pick ONE invalid case at random.
      const invalidClass = pick(['invalid_flavor', 'git_unavailable', 'parse_level']);
      const ctx = `iter=${i} class='${invalidClass}'`;

      if (invalidClass === 'invalid_flavor') {
        // (a) INVALID FLAVOR passed to saveAllToFlavor, with a spawn that WOULD
        //     succeed if reached — proving rejection precedes any git/copy I/O
        //     (Req 13.6).
        let flavor;
        do {
          flavor = randomName(1, 8);
        } while (FLAVORS.includes(flavor));

        const okFakeSpawn = makeOkFakeSpawn(repoRoot);
        const code = withSilencedConsole(() =>
          saveAllToFlavor(repoRoot, flavor, { spawn: okFakeSpawn }),
        );
        assert.equal(
          code,
          1,
          `saveAllToFlavor must return 1 for an invalid flavor (${ctx} flavor='${flavor}')`,
        );
      } else if (invalidClass === 'git_unavailable') {
        // (b) GIT UNAVAILABLE: valid flavor but a failing spawn (git missing or
        //     not-a-repo) → non-zero, no mutation (Req 13.7).
        const flavor = pick(FLAVORS);
        const failingSpawn = makeFailingSpawn();
        const code = withSilencedConsole(() =>
          saveAllToFlavor(repoRoot, flavor, { spawn: failingSpawn }),
        );
        assert.equal(
          code,
          1,
          `saveAllToFlavor must return 1 when Git is unavailable (${ctx} flavor='${flavor}')`,
        );
      } else {
        // (c) PARSE-LEVEL rejections — no I/O possible at the parse layer, but we
        //     still snapshot-check the repo is untouched (Req 13.9, 13.10).

        // `--all` without `--save-to-flavor`.
        const noSaveTo = withSilencedConsole(() =>
          parseCliArgs(['node', 'x', '--all']),
        );
        assert.equal(noSaveTo.ok, false, `--all without --save-to-flavor must be rejected (${ctx})`);
        assert.match(
          noSaveTo.error,
          /--all requires --save-to-flavor/,
          `--all without --save-to-flavor must report the expected error (${ctx})`,
        );

        // `--all` together with `--restore-base` (plus a valid --save-to-flavor).
        const conflict = withSilencedConsole(() =>
          parseCliArgs(['node', 'x', '--restore-base', '--all', '--save-to-flavor=dev']),
        );
        assert.equal(
          conflict.ok,
          false,
          `--restore-base + --all must be rejected (${ctx})`,
        );
        assert.ok(
          typeof conflict.error === 'string' && conflict.error.length > 0,
          `--restore-base + --all must report a conflict error (${ctx})`,
        );
      }

      // FULL repo-tree snapshot AFTER must equal BEFORE: nothing created,
      // overwritten, or deleted by any of the invalid cases.
      const after = await snapshotRepoTree(repoRoot);
      assertSnapshotsEqual(before, after, ctx);
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
