// main-dry-run.test.mjs
//
// Tests for the `--dry-run` preview flag of main() (task 13.2).
//
// --dry-run runs discovery, planning, and manifest diffing and PRINTS what the
// real run WOULD copy, delete, and the pubspec line it WOULD remove — WITHOUT
// touching the filesystem. These tests assert the preview output AND, crucially,
// that the repo tree is byte-identical after the run (nothing mutated) and that
// workspace resolution is never spawned.
//
// _Requirements: 1.2, 1.3, 3.1_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';

import { main } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

/**
 * Run `fn` while capturing console.log/console.error output as line arrays.
 * @template T
 * @param {() => T} fn
 * @returns {{ result: T, stdout: string[], stderr: string[] }}
 */
function captureConsole(fn) {
  const stdout = [];
  const stderr = [];
  const origLog = console.log;
  const origError = console.error;
  console.log = (...args) => stdout.push(args.map((a) => String(a)).join(' '));
  console.error = (...args) => stderr.push(args.map((a) => String(a)).join(' '));
  try {
    const result = fn();
    return { result, stdout, stderr };
  } finally {
    console.log = origLog;
    console.error = origError;
  }
}

/** Build argv in the shape main() expects: node, script, flavor, ...flags. */
function argv(flavor, ...flags) {
  return ['node', 'switch-flavor.mjs', flavor, ...flags];
}

/**
 * Take a full snapshot of a directory tree as a map of repo-relative POSIX path
 * -> sha256 hash of the file's bytes. Lets a test assert the tree is
 * byte-identical before and after a run (nothing created, deleted, or modified).
 * @param {string} root absolute path to the directory to snapshot
 * @returns {Record<string,string>}
 */
function snapshotTree(root) {
  const snapshot = {};
  const walk = (dir) => {
    for (const dirent of fs.readdirSync(dir, { withFileTypes: true })) {
      const abs = path.join(dir, dirent.name);
      if (dirent.isDirectory()) {
        walk(abs);
      } else if (dirent.isFile()) {
        const rel = path.relative(root, abs).split(path.sep).join('/');
        const hash = crypto.createHash('sha256').update(fs.readFileSync(abs)).digest('hex');
        snapshot[rel] = hash;
      }
    }
  };
  walk(root);
  return snapshot;
}

// ---------------------------------------------------------------------------
// 1. Dry-run with a pre-existing VALID manifest: preview lists would-copy and
//    would-delete files; the whole repo tree is byte-identical afterwards.
//    (Req 1.2, 1.3, 3.1)
// ---------------------------------------------------------------------------

test('--dry-run: lists would-copy/would-delete, mutates nothing (Req 1.2, 1.3, 3.1)', async () => {
  const dir = await makeTempDir();
  try {
    // A component owns the dev flavor folder, plus a pre-existing VALID manifest
    // listing some lib files from a prior switch.
    await buildRepo(dir, {
      components: [
        {
          name: 'sfera',
          lib: { 'src/old_a.dart': 'OLD A\n', 'src/old_b.dart': 'OLD B\n' },
          flavors: { dev: { 'lib/src/foo.dart': 'DEV FOO\n', 'lib/src/bar.dart': 'DEV BAR\n' } },
        },
      ],
      manifest: {
        version: 2,
        flavor: 'inte',
        generatedAt: '2024-01-01T00:00:00.000Z',
        files: [
          { path: 'sfera/lib/src/old_a.dart', overwrote: false },
          { path: 'sfera/lib/src/old_b.dart', overwrote: false },
        ],
      },
    });

    const before = snapshotTree(dir);

    const { result, stdout } = captureConsole(() => main(argv('dev', '--dry-run'), { repoRoot: dir }));

    assert.equal(result, 0, '--dry-run must succeed with exit 0');

    const out = stdout.join('\n');
    // Preview names the flavor.
    assert.ok(/\[dry-run\].*dev/.test(out), `expected the flavor in the preview; got:\n${out}`);
    // Would-copy targets listed.
    assert.ok(out.includes('sfera/lib/src/foo.dart'), 'would-copy must list sfera/lib/src/foo.dart');
    assert.ok(out.includes('sfera/lib/src/bar.dart'), 'would-copy must list sfera/lib/src/bar.dart');
    // Would-delete targets (from the VALID manifest) listed.
    assert.ok(out.includes('sfera/lib/src/old_a.dart'), 'would-delete must list sfera/lib/src/old_a.dart');
    assert.ok(out.includes('sfera/lib/src/old_b.dart'), 'would-delete must list sfera/lib/src/old_b.dart');

    const after = snapshotTree(dir);
    assert.deepEqual(after, before, 'the repo tree must be byte-identical after a dry-run');
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 2. Dry-run with --remove-dep: reports the line would be removed, pubspec is
//    byte-identical afterwards, and spawn was never called. (Req 1.3)
// ---------------------------------------------------------------------------

test('--dry-run --remove-dep: reports removal, pubspec untouched, no spawn (Req 1.3)', async () => {
  const dir = await makeTempDir();
  try {
    await buildRepo(dir, {
      components: [{ name: 'sfera', flavors: { dev: { 'lib/src/foo.dart': 'DEV\n' } } }],
    });

    const pubspecPath = path.join(dir, 'app', 'pubspec.yaml');
    const pubspecBefore = fs.readFileSync(pubspecPath, 'utf8');
    const treeBefore = snapshotTree(dir);

    const calls = [];
    const spawn = (cmd, spawnArgs, opts) => {
      calls.push({ cmd, spawnArgs, opts });
      return { status: 0 };
    };

    const { result, stdout } = captureConsole(() =>
      main(argv('dev', '--remove-dep=warnapp', '--dry-run'), { repoRoot: dir, spawn }),
    );

    assert.equal(result, 0, '--dry-run with --remove-dep must succeed with exit 0');

    const out = stdout.join('\n');
    assert.ok(
      /warnapp.*would be removed.*found/i.test(out),
      `expected a "would be removed (found)" report for warnapp; got:\n${out}`,
    );

    const pubspecAfter = fs.readFileSync(pubspecPath, 'utf8');
    assert.equal(pubspecAfter, pubspecBefore, 'app/pubspec.yaml must be byte-identical after a dry-run');

    assert.equal(calls.length, 0, 'spawn must NEVER be called in dry-run mode');

    const treeAfter = snapshotTree(dir);
    assert.deepEqual(treeAfter, treeBefore, 'the repo tree must be byte-identical after a dry-run');
  } finally {
    await removeTempDir(dir);
  }
});

// ---------------------------------------------------------------------------
// 3. Dry-run no-match case still returns 1 (the no-match check applies before
//    the preview). (Req 1.2)
// ---------------------------------------------------------------------------

test('--dry-run: folderless flavor previews a no-op and returns 0 (Req 1.5, 6.3)', async () => {
  const dir = await makeTempDir();
  try {
    // Components have lib/ but NO dev/ flavor folder → empty copy plan. A
    // folderless flavor is a successful no-op (the flavor uses the base code).
    await buildRepo(dir, {
      components: [{ name: 'sfera', lib: { 'a.dart': '//a\n' } }],
    });

    const before = snapshotTree(dir);

    const { result, stdout } = captureConsole(() =>
      main(argv('dev', '--dry-run'), { repoRoot: dir }),
    );

    assert.equal(result, 0, 'a folderless flavor must exit 0 even in dry-run');
    assert.ok(
      stdout.some((line) => /\[dry-run\].*base code unchanged|nothing would be switched/i.test(line)),
      `expected a "[dry-run] ... base code unchanged" preview; got: ${JSON.stringify(stdout)}`,
    );

    const after = snapshotTree(dir);
    assert.deepEqual(after, before, 'the repo tree must be byte-identical after a no-match dry-run');
  } finally {
    await removeTempDir(dir);
  }
});
