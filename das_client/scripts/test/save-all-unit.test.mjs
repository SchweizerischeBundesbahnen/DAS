// save-all-unit.test.mjs
//
// Deterministic example/unit tests for the `--save-to-flavor --all` feature:
//   Group A — parseCliArgs --all validation (success shape + the two conflicts).
//   Group B — gitChangedSourceFiles porcelain parsing against an injected fake
//             spawn (hermetic: no real git; present/deleted classified by on-disk
//             existence; rename extra-NUL-field alignment; the lib/+test/ source
//             filter keeps both roots and drops non-source paths).
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

import { parseCliArgs, gitChangedSourceFiles, main, FLAVORS } from '../switch-flavor.mjs';
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
 * Build a fake `spawn` matching the gitChangedSourceFiles call contract:
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
// GROUP B — gitChangedSourceFiles porcelain parsing (fake spawn, hermetic)
// ===========================================================================

test('Group B: parses untracked/deleted/rename porcelain across lib/ and test/ and drops non-source paths', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-git-');
  try {
    const comp = 'sfera';
    // Build a repo with the component and the source files that must exist on
    // disk (so they classify as `present`), across BOTH lib/ and test/ roots. Do
    // NOT create the deleted files.
    await buildRepo(repoRoot, {
      components: [
        {
          name: comp,
          lib: {
            'u.dart': 'untracked present',
            'new.dart': 'renamed-to present',
            'after.dart': 'after-the-rename present',
          },
          test: {
            'u_test.dart': 'untracked present (test root)',
          },
        },
      ],
    });

    // Craft a NUL-separated porcelain -z stream. Record format: `XY<space>PATH\0`.
    // A rename record `R  <new>` is followed by a SEPARATE NUL field holding the
    // ORIGINAL path, which the parser must consume so later records stay aligned.
    const porcelain = [
      `?? ${comp}/lib/u.dart\0`, // untracked lib/, exists on disk → present
      ` D ${comp}/lib/d.dart\0`, // deleted lib/, NOT on disk → deleted
      `R  ${comp}/lib/new.dart\0${comp}/lib/old.dart\0`, // rename: new (present) + old (deleted) as extra NUL field
      `?? ${comp}/u.dart\0`, // NON-source (directly under component) → filtered out
      `?? ${comp}/test/u_test.dart\0`, // untracked test/, exists on disk → present
      ` D ${comp}/test/d_test.dart\0`, // deleted test/, NOT on disk → deleted
      `?? ${comp}/lib/after.dart\0`, // proves alignment after the rename record → present
    ].join('');

    const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

    const result = gitChangedSourceFiles(repoRoot, fakeSpawn);
    assert.equal(result.ok, true);

    const expected = sortEntries([
      { path: `${comp}/lib/u.dart`, status: 'present' },
      { path: `${comp}/lib/d.dart`, status: 'deleted' },
      { path: `${comp}/lib/new.dart`, status: 'present' },
      { path: `${comp}/lib/old.dart`, status: 'deleted' }, // rename original, not on disk
      { path: `${comp}/test/u_test.dart`, status: 'present' }, // test/ root kept
      { path: `${comp}/test/d_test.dart`, status: 'deleted' }, // deleted test/ kept
      { path: `${comp}/lib/after.dart`, status: 'present' }, // alignment proof
    ]);

    assert.deepEqual(sortEntries(result.files), expected);

    // The non-source path (directly under the component) must be filtered out.
    assert.ok(
      !result.files.some((e) => e.path === `${comp}/u.dart`),
      'non-source path (no lib/ or test/ root) must be filtered out',
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

    const result = gitChangedSourceFiles(repoRoot, failingSpawn);
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

    const result = gitChangedSourceFiles(repoRoot, enoentSpawn);
    assert.deepEqual(result, { ok: false, reason: 'git_unavailable' });
  } finally {
    await removeTempDir(repoRoot);
  }
});

// ===========================================================================
// GROUP C — main dispatch wiring
// ===========================================================================

test('Group C: main --all routes to saveAllToFlavor and threads the injected spawn (both roots)', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-main-');
  try {
    const comp = 'sfera';
    const libRest = 'src/foo.dart';
    const testRest = 'src/foo_test.dart';
    await buildRepo(repoRoot, {
      components: [
        {
          name: comp,
          lib: { [libRest]: 'hello from lib' },
          test: { [testRest]: 'hello from test' },
        },
      ],
    });

    // Fake spawn: rev-parse → repoRoot, status → one present lib change and one
    // present test change.
    const porcelain = `?? ${comp}/lib/${libRest}\0?? ${comp}/test/${testRest}\0`;
    const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

    const code = withSilencedConsole(() =>
      main(['node', 'x', '--save-to-flavor=dev', '--all'], { repoRoot, spawn: fakeSpawn }),
    );
    assert.equal(code, 0, 'main --all must return 0');

    // Proof main routed --all → saveAllToFlavor (which threaded the fake spawn):
    // the flavor copies at <comp>/.dev/lib/<rest> and <comp>/.dev/test/<rest> were
    // created from the changed source files, preserving the source root segment.
    const libDest = path.join(repoRoot, comp, '.dev', 'lib', libRest);
    assert.ok(fs.existsSync(libDest), `flavor copy must exist at ${comp}/.dev/lib/${libRest}`);
    assert.equal(await fsp.readFile(libDest, 'utf8'), 'hello from lib');

    const testDest = path.join(repoRoot, comp, '.dev', 'test', testRest);
    assert.ok(fs.existsSync(testDest), `flavor copy must exist at ${comp}/.dev/test/${testRest}`);
    assert.equal(await fsp.readFile(testDest, 'utf8'), 'hello from test');
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

    // The single file was copied to the flavor folder preserving the source root
    // segment (<comp>/.dev/lib/<rest>), source left in place.
    const destAbs = path.join(repoRoot, comp, '.dev', 'lib', rest);
    assert.ok(fs.existsSync(destAbs), `flavor copy must exist at ${comp}/.dev/lib/${rest}`);
    assert.equal(await fsp.readFile(destAbs, 'utf8'), 'single file content');
    assert.ok(fs.existsSync(path.join(repoRoot, file)), 'source lib/ file must still exist');
  } finally {
    await removeTempDir(repoRoot);
  }
});
