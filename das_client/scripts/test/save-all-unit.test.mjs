// save-all-unit.test.mjs
//
// Deterministic example/unit tests for the `--save-to-flavor --all` feature:
//   Group A — parseCliArgs --all validation (success shape + the two conflicts).
//   Group B — gitChangedLibFiles porcelain parsing against an injected fake spawn
//             (hermetic: no real git; present/deleted classified by on-disk
//             existence; rename extra-NUL-field alignment; non-lib filter).
//   Group C — main dispatch wiring (--all routes to saveAllToFlavor with the
//             injected spawn; the single-file branch never touches git).
//
// Validates: Requirements 13.1, 13.2, 13.4, 13.5, 13.6, 13.9, 13.10
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { parseCliArgs, gitChangedLibFiles, main, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/** Silence console.log/console.error for the duration of `fn`, then restore. */
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
 * Build a fake `spawn` matching the gitChangedLibFiles call contract:
 *   - `git -C <repoRoot> rev-parse --show-toplevel` → `{status:0, stdout: repoRoot+'\n'}`
 *     (toplevel === repoRoot so porcelain paths are repoRoot-relative)
 *   - `git -C <repoRoot> status --porcelain -z`      → `{status:0, stdout: porcelain}`
 * The subcommand is detected by inspecting the args array.
 *
 * @param {string} repoRoot
 * @param {string} porcelain NUL-separated `status --porcelain -z` stdout
 */
function makeFakeSpawn(repoRoot, porcelain) {
  return (cmd, args /*, opts */) => {
    if (Array.isArray(args) && args.includes('rev-parse')) {
      return { status: 0, stdout: `${repoRoot}\n`, error: undefined };
    }
    if (Array.isArray(args) && args.includes('status')) {
      return { status: 0, stdout: porcelain, error: undefined };
    }
    return { status: 1, stdout: '', error: new Error(`unexpected git call: ${cmd} ${args}`) };
  };
}

/** Sort an array of `{path, status}` by path for order-independent comparison. */
function sortEntries(entries) {
  return [...entries].sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));
}

// ===========================================================================
// GROUP A — parseCliArgs --all validation
// ===========================================================================

test('Group A: --all without --save-to-flavor is a validation error (Req 13.9)', () => {
  const result = parseCliArgs(['node', 'x', '--all']);
  assert.equal(result.ok, false);
  assert.match(result.error, /--all requires --save-to-flavor/);
});

test('Group A: --all combined with --restore-base is a validation error (Req 13.10)', () => {
  // Note: `--restore-base --all --save-to-flavor=dev` would hit the earlier
  // restore-base + save-to-flavor conflict check first. To exercise the
  // "--all cannot be combined with --restore-base" branch, pass --restore-base
  // --all WITHOUT --save-to-flavor so that conflict check fires.
  const result = parseCliArgs(['node', 'x', '--restore-base', '--all']);
  assert.equal(result.ok, false);
  assert.equal(result.error, '--all cannot be combined with --restore-base');
});

test('Group A: --save-to-flavor=dev --all succeeds with all:true and file:undefined', () => {
  const result = parseCliArgs(['node', 'x', '--save-to-flavor=dev', '--all']);
  assert.equal(result.ok, true);
  assert.deepEqual(result.saveToFlavor, { flavor: 'dev', file: undefined, all: true });
});

test('Group A: --save-to-flavor=dev <file> (no --all) carries the positional with all:false', () => {
  const result = parseCliArgs(['node', 'x', '--save-to-flavor=dev', 'some/lib/f.dart']);
  assert.equal(result.ok, true);
  assert.deepEqual(result.saveToFlavor, { flavor: 'dev', file: 'some/lib/f.dart', all: false });
});

test('Group A: invalid flavor is still rejected under --all (Req 13.6)', () => {
  const result = parseCliArgs(['node', 'x', '--save-to-flavor=bogus', '--all']);
  assert.equal(result.ok, false);
  assert.match(result.error, /Not a valid flavor: 'bogus'/);
});

// ===========================================================================
// GROUP B — gitChangedLibFiles porcelain parsing (fake spawn, hermetic)
// ===========================================================================

test('Group B: parses untracked/deleted/rename/non-lib porcelain and classifies by disk existence', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-git-');
  try {
    const comp = 'sfera';
    // Build a repo with the component and the lib files that must exist on disk
    // (so they classify as `present`). Do NOT create the deleted file.
    await buildRepo(repoRoot, {
      components: [
        {
          name: comp,
          lib: {
            'u.dart': 'untracked present',
            'new.dart': 'renamed-to present',
            'after.dart': 'after-the-rename present',
          },
        },
      ],
    });

    // Craft a NUL-separated porcelain -z stream. Record format: `XY<space>PATH\0`.
    // A rename record `R  <new>` is followed by a SEPARATE NUL field holding the
    // ORIGINAL path, which the parser must consume so later records stay aligned.
    const porcelain = [
      `?? ${comp}/lib/u.dart\0`, // untracked, exists on disk → present
      ` D ${comp}/lib/d.dart\0`, // deleted, NOT on disk → deleted
      `R  ${comp}/lib/new.dart\0${comp}/lib/old.dart\0`, // rename: new (present) + old (deleted) as extra NUL field
      `?? ${comp}/test/x.dart\0`, // NON-lib → filtered out
      `?? ${comp}/lib/after.dart\0`, // proves alignment after the rename record → present
    ].join('');

    const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

    const result = gitChangedLibFiles(repoRoot, fakeSpawn);
    assert.equal(result.ok, true);

    const expected = sortEntries([
      { path: `${comp}/lib/u.dart`, status: 'present' },
      { path: `${comp}/lib/d.dart`, status: 'deleted' },
      { path: `${comp}/lib/new.dart`, status: 'present' },
      { path: `${comp}/lib/old.dart`, status: 'deleted' }, // rename original, not on disk
      { path: `${comp}/lib/after.dart`, status: 'present' }, // alignment proof
    ]);

    assert.deepEqual(sortEntries(result.files), expected);

    // The non-lib test/ path must be filtered out entirely.
    assert.ok(
      !result.files.some((e) => e.path === `${comp}/test/x.dart`),
      'non-lib test/ path must be filtered out',
    );
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('Group B: git unavailable (rev-parse status 128) → { ok:false, reason:"git_unavailable" }', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-git-unavail-');
  try {
    await buildRepo(repoRoot, { components: [{ name: 'sfera', lib: { 'a.dart': 'x' } }] });

    const failingSpawn = (cmd, args) => {
      if (Array.isArray(args) && args.includes('rev-parse')) {
        return { status: 128, stdout: '', error: undefined };
      }
      throw new Error('status should not be called when rev-parse fails');
    };

    const result = gitChangedLibFiles(repoRoot, failingSpawn);
    assert.deepEqual(result, { ok: false, reason: 'git_unavailable' });
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('Group B: git missing (rev-parse spawn error ENOENT) → { ok:false, reason:"git_unavailable" }', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-git-enoent-');
  try {
    await buildRepo(repoRoot, { components: [{ name: 'sfera', lib: { 'a.dart': 'x' } }] });

    const enoentSpawn = (cmd, args) => {
      if (Array.isArray(args) && args.includes('rev-parse')) {
        const err = new Error('spawn git ENOENT');
        err.code = 'ENOENT';
        return { status: null, stdout: '', error: err };
      }
      throw new Error('status should not be called when rev-parse fails');
    };

    const result = gitChangedLibFiles(repoRoot, enoentSpawn);
    assert.deepEqual(result, { ok: false, reason: 'git_unavailable' });
  } finally {
    await removeTempDir(repoRoot);
  }
});

// ===========================================================================
// GROUP C — main dispatch wiring
// ===========================================================================

test('Group C: main --all routes to saveAllToFlavor and threads the injected spawn', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-main-');
  try {
    const comp = 'sfera';
    const rest = 'src/foo.dart';
    await buildRepo(repoRoot, {
      components: [{ name: comp, lib: { [rest]: 'hello from lib' } }],
    });

    // Fake spawn: rev-parse → repoRoot, status → one present lib change.
    const porcelain = `?? ${comp}/lib/${rest}\0`;
    const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

    const code = withSilencedConsole(() =>
      main(['node', 'x', '--save-to-flavor=dev', '--all'], { repoRoot, spawn: fakeSpawn }),
    );
    assert.equal(code, 0, 'main --all must return 0');

    // Proof main routed --all → saveAllToFlavor (which threaded the fake spawn):
    // the flavor copy <comp>/dev/<rest> was created from the changed lib file.
    const destAbs = path.join(repoRoot, comp, '.dev', rest);
    assert.ok(fs.existsSync(destAbs), `flavor copy must exist at ${comp}/dev/${rest}`);
    const destBytes = await fsp.readFile(destAbs, 'utf8');
    assert.equal(destBytes, 'hello from lib');
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('Group C: main single-file --save-to-flavor (no --all) never touches git', async () => {
  const repoRoot = await makeTempDir('flavor-save-single-main-');
  try {
    const comp = 'sfera';
    const rest = 'src/bar.dart';
    const file = `${comp}/lib/${rest}`;
    await buildRepo(repoRoot, {
      components: [{ name: comp, lib: { [rest]: 'single file content' } }],
    });

    // A spawn that throws if called — proves the non-all branch never invokes git.
    const throwingSpawn = () => {
      throw new Error('git must not be spawned in the single-file save branch');
    };

    const code = withSilencedConsole(() =>
      main(['node', 'x', '--save-to-flavor=dev', file], { repoRoot, spawn: throwingSpawn }),
    );
    assert.equal(code, 0, 'main single-file save must return 0');

    // The single file was copied to the flavor folder, source left in place.
    const destAbs = path.join(repoRoot, comp, '.dev', rest);
    assert.ok(fs.existsSync(destAbs), `flavor copy must exist at ${comp}/dev/${rest}`);
    assert.equal(await fsp.readFile(destAbs, 'utf8'), 'single file content');
    assert.ok(fs.existsSync(path.join(repoRoot, file)), 'source lib/ file must still exist');
  } finally {
    await removeTempDir(repoRoot);
  }
});
