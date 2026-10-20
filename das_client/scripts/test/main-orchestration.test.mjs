// main-orchestration.test.mjs
//
// Example/integration tests for the `main()` orchestrator (task 10.9).
//
// Exercises main() end-to-end against temp-dir fixtures, asserting on its
// returned exit code (main never calls process.exit) and on the lines it writes
// to stdout/stderr (captured by temporarily replacing console.log/console.error).
//
// Covers:
//   1. "deletion skipped" report on MISSING and CORRUPT manifest (Req 4.3)
//   2. "no matching flavor folder" report + non-zero exit (Req 6.3, 6.4)
//   3. refreshResolution invoked with correct command/cwd ONLY when a
//      dependency was removed (Req 8.1)
//   4. simulated non-zero resolution exit reported with non-zero exit (Req 8.2)
//   5. exact command printed when the toolchain is unavailable (Req 8.1)
//
// _Requirements: 4.3, 6.3, 6.4, 8.1, 8.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

import { main } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

/**
 * Run `fn` while capturing everything written through console.log/console.error.
 * Each argument of a call is stringified and joined with a space to form one
 * captured line. Restores the originals afterwards even on failure.
 *
 * @template T
 * @param {() => T} fn
 * @returns {{ result: T, stdout: string[], stderr: string[] }}
 */
function captureConsole(fn) {
  const stdout = [];
  const stderr = [];
  const origLog = console.log;
  const origError = console.error;
  const origWarn = console.warn;
  console.log = (...args) => stdout.push(args.map((a) => String(a)).join(' '));
  console.error = (...args) => stderr.push(args.map((a) => String(a)).join(' '));
  // Warnings are informational; capture them alongside stderr so a test can
  // assert on a warning without treating it as the error channel.
  console.warn = (...args) => stderr.push(args.map((a) => String(a)).join(' '));
  try {
    const result = fn();
    return { result, stdout, stderr };
  } finally {
    console.log = origLog;
    console.error = origError;
    console.warn = origWarn;
  }
}

/** Build argv in the shape main() expects: node, script, flavor, ...flags. */
function argv(flavor, ...flags) {
  return ['node', 'switch-flavor.mjs', flavor, ...flags];
}

// ---------------------------------------------------------------------------
// 1. "deletion skipped" on MISSING / CORRUPT manifest (Req 4.3)
// ---------------------------------------------------------------------------

test('MISSING manifest: deletion skipped, exit 0 (Req 4.3)', async () => {
  const dir = await makeTempDir();
  try {
    // A component owns the dev flavor folder; no manifest is written.
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const { result, stdout } = captureConsole(() => main(argv('dev'), { repoRoot: dir }));

    assert.equal(result, 0, 'first-run (no manifest) must succeed with exit 0');
    assert.ok(
      stdout.some((line) => /deletion skipped/i.test(line)),
      `expected a "deletion skipped" line on stdout; got: ${JSON.stringify(stdout)}`,
    );
  } finally {
    await removeTempDir(dir);
  }
});

test('CORRUPT manifest: deletion skipped, exit 0 (Req 4.3)', async () => {
  const dir = await makeTempDir();
  try {
    // Component owns the dev flavor folder; manifest is non-JSON (corrupt).
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
      manifestRaw: '{ this is not valid json',
    });

    const { result, stdout } = captureConsole(() => main(argv('dev'), { repoRoot: dir }));

    assert.equal(result, 0, 'corrupt manifest must fall back to copy-only and succeed');
    assert.ok(
      stdout.some((line) => /deletion skipped/i.test(line)),
      `expected a "deletion skipped" line on stdout; got: ${JSON.stringify(stdout)}`,
    );
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 2. "no matching flavor folder" + non-zero exit (Req 6.3, 6.4)
// ---------------------------------------------------------------------------

test('no component owns the flavor folder: warning + exit 0, base unchanged (Req 1.5, 6.3)', async () => {
  const dir = await makeTempDir();
  try {
    // Components have lib/ but NO dev/ flavor folder → empty copy plan. This is
    // NOT an error: the flavor uses the base code unchanged (warning, exit 0).
    await buildRepo(dir, {
      components: [
        { name: 'sfera', lib: { 'a.dart': '//a\n' } },
        { name: 'warnapp', lib: { 'b.dart': '//b\n' } },
      ],
    });

    const { result, stderr } = captureConsole(() => main(argv('dev'), { repoRoot: dir }));

    assert.equal(result, 0, 'an empty copy plan (folderless flavor) must exit 0');
    assert.ok(
      stderr.some((line) => /uses the base code unchanged|nothing to switch/i.test(line)),
      `expected a folderless-flavor warning; got: ${JSON.stringify(stderr)}`,
    );
    // No manifest is written for a folderless flavor (no switch happened).
    assert.equal(
      fs.existsSync(path.join(dir, '.flavor-manifest.json')),
      false,
      'no manifest should be written when the flavor has no folder',
    );
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 3. refreshResolution invoked only when a dependency was removed (Req 8.1)
// ---------------------------------------------------------------------------

test('--remove-dep: resolution spawned once with correct command/cwd, exit 0 (Req 8.1)', async () => {
  const dir = await makeTempDir();
  try {
    // Component owns the dev folder; default app pubspec has sfera + warnapp.
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const calls = [];
    const spawn = (cmd, args, opts) => {
      calls.push({ cmd, args, opts });
      return { status: 0 };
    };

    const { result } = captureConsole(() =>
      main(argv('dev', '--remove-dep=warnapp'), { repoRoot: dir, spawn }),
    );

    assert.equal(result, 0, 'successful resolution must exit 0');
    assert.equal(calls.length, 1, 'spawn must be called exactly once');
    assert.equal(calls[0].cmd, 'fvm', "spawn command must be 'fvm'");
    assert.deepEqual(
      calls[0].args,
      ['dart', 'run', 'melos', 'bootstrap'],
      'spawn args must be the melos bootstrap command',
    );
    assert.equal(calls[0].opts.cwd, dir, 'spawn cwd must be the repo root');
  } finally {
    await removeTempDir(dir);
  }
});

test('without --remove-dep: resolution is NOT spawned (Req 8.1)', async () => {
  const dir = await makeTempDir();
  try {
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const calls = [];
    const spawn = (cmd, args, opts) => {
      calls.push({ cmd, args, opts });
      return { status: 0 };
    };

    const { result } = captureConsole(() => main(argv('dev'), { repoRoot: dir, spawn }));

    assert.equal(result, 0, 'a plain switch must succeed');
    assert.equal(calls.length, 0, 'spawn must NOT be called without --remove-dep');
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 4. non-zero resolution exit reported with non-zero exit (Req 8.2)
// ---------------------------------------------------------------------------

test('--remove-dep: non-zero resolution exit reported, main exits 1 (Req 8.2)', async () => {
  const dir = await makeTempDir();
  try {
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const spawn = () => ({ status: 1 });

    const { result, stderr } = captureConsole(() =>
      main(argv('dev', '--remove-dep=warnapp'), { repoRoot: dir, spawn }),
    );

    assert.equal(result, 1, 'a non-zero resolution exit must make main exit 1');
    assert.ok(
      stderr.some((line) => /resolution/i.test(line) && /1/.test(line)),
      `expected a stderr line reporting the resolution failure and exit status; got: ${JSON.stringify(stderr)}`,
    );
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 5. exact command printed when the toolchain is unavailable (Req 8.1)
// ---------------------------------------------------------------------------

test('--remove-dep: toolchain unavailable prints exact command, exit 1 (Req 8.1)', async () => {
  const dir = await makeTempDir();
  try {
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const spawn = () => ({
      error: Object.assign(new Error('spawn fvm ENOENT'), { code: 'ENOENT' }),
    });

    const { result, stderr } = captureConsole(() =>
      main(argv('dev', '--remove-dep=warnapp'), { repoRoot: dir, spawn }),
    );

    assert.equal(result, 1, 'an unspawnable toolchain must make main exit 1');
    assert.ok(
      stderr.some((line) => line.includes('fvm dart run melos bootstrap')),
      `expected a stderr line containing the exact command; got: ${JSON.stringify(stderr)}`,
    );
  } finally {
    await removeTempDir(dir);
  }
});
