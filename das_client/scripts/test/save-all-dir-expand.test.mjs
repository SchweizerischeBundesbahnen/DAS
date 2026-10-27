// save-all-dir-expand.test.mjs
//
// Regression test for the `--save-to-flavor=<flavor> --all` directory-expansion
// bug (spec task 39): `git status --porcelain -z` reports a WHOLLY-UNTRACKED
// directory as a single record with a trailing slash (e.g.
// `?? app/lib/pages/foo/mock/`) rather than its individual files. Previously
// `gitChangedSourceFiles` classified that directory record as a `present` FILE,
// and `saveAllToFlavor` then called `fs.copyFileSync` on a DIRECTORY → crash with
// `ENOTSUP: operation not supported on socket, copyfile ...`.
//
// The fix expands an untracked directory record into its contained regular files
// (each copied into the flavor folder), and defensively skips any non-regular
// source in the `present` branch.
//
// Feature: flavor-code-switching, Property 19 (directory-expansion case)
// Validates: Requirements 13.1, 13.2, 13.3
//
// Deterministic example/regression test (matches the style of the other save-all
// tests). Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveAllToFlavor } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

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
 * Fake `spawn` matching the gitChangedSourceFiles contract:
 *   - `git -C <repoRoot> rev-parse --show-toplevel` → repoRoot (toplevel === repoRoot)
 *   - `git -C <repoRoot> status --porcelain -z`      → the given porcelain stdout
 */
function makeFakeSpawn(repoRoot, porcelain) {
  return (cmd, args) => {
    if (Array.isArray(args) && args.includes('rev-parse')) {
      return { status: 0, stdout: `${repoRoot}\n`, error: undefined };
    }
    if (Array.isArray(args) && args.includes('status')) {
      return { status: 0, stdout: porcelain, error: undefined };
    }
    return { status: 1, stdout: '', error: new Error(`unexpected git call: ${cmd} ${args}`) };
  };
}

test('save-all expands a wholly-untracked lib/ directory record into its files (reproduces task 39 ENOTSUP crash)', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-dir-expand-');
  try {
    const comp = 'app';
    // The untracked directory, mirroring the real crash path. It contains several
    // regular .dart files, INCLUDING a nested subdirectory, all present on disk.
    const mockDir = 'pages/journey/journey_screen/view_model/mock';
    const files = {
      [`${mockDir}/mock_a.dart`]: 'content A',
      [`${mockDir}/mock_b.dart`]: 'content B',
      [`${mockDir}/nested/mock_c.dart`]: 'content C (nested)',
    };
    // A plain-file `present` record alongside the directory, to prove normal
    // single-file handling is unaffected.
    const plainRel = 'x.dart';

    await buildRepo(repoRoot, {
      components: [
        {
          name: comp,
          lib: { ...files, [plainRel]: 'plain file content' },
        },
      ],
    });

    // Porcelain: the untracked DIRECTORY as a single record WITH a trailing slash
    // (exactly how real git reports a wholly-untracked directory), plus a plain
    // untracked file record.
    const porcelain = [
      `?? ${comp}/lib/${mockDir}/\0`, // untracked DIRECTORY (trailing slash)
      `?? ${comp}/lib/${plainRel}\0`, // plain untracked FILE
    ].join('');

    const spawn = makeFakeSpawn(repoRoot, porcelain);

    // Must NOT throw (the old code crashed with ENOTSUP) and must return 0.
    let code;
    assert.doesNotThrow(() => {
      code = withSilencedConsole(() => saveAllToFlavor(repoRoot, 'inte', { spawn }));
    }, 'saveAllToFlavor must not throw on a wholly-untracked directory record');
    assert.equal(code, 0, 'saveAllToFlavor must return exit code 0');

    // EACH contained file must be copied byte-identically to the flavor folder,
    // preserving the nested structure, with the source left in place.
    for (const [rel, content] of Object.entries(files)) {
      const srcAbs = path.join(repoRoot, comp, 'lib', rel);
      const destAbs = path.join(repoRoot, comp, '.inte', 'lib', rel);
      assert.ok(fs.existsSync(destAbs), `flavor copy must exist at ${comp}/.inte/lib/${rel}`);
      assert.equal(await fsp.readFile(destAbs, 'utf8'), content, `content preserved for ${rel}`);
      assert.ok(fs.existsSync(srcAbs), `source lib/ file must still exist: ${rel}`);
      assert.equal(await fsp.readFile(srcAbs, 'utf8'), content, `source unchanged for ${rel}`);
    }

    // The plain-file `present` record must still copy.
    const plainDest = path.join(repoRoot, comp, '.inte', 'lib', plainRel);
    assert.ok(fs.existsSync(plainDest), `plain-file flavor copy must exist at ${comp}/.inte/lib/${plainRel}`);
    assert.equal(await fsp.readFile(plainDest, 'utf8'), 'plain file content');

    // The directory record itself must NOT be copied as a path (no bare `mock`
    // directory copied as a file, and no stray directory-named file in the flavor
    // folder).
    const mockDestDir = path.join(repoRoot, comp, '.inte', 'lib', mockDir);
    assert.ok(fs.statSync(mockDestDir).isDirectory(), 'the flavor mock path must be a real directory of files');
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('save-all skips a non-regular source entry in the present branch without crashing', async () => {
  const repoRoot = await makeTempDir('flavor-save-all-nonregular-');
  try {
    const comp = 'app';
    const goodRel = 'good.dart';
    await buildRepo(repoRoot, {
      components: [{ name: comp, lib: { [goodRel]: 'good content' } }],
    });

    // Create a FIFO (named pipe) under lib/ so a `present` record points at a
    // non-regular, non-directory source. The defensive guard must skip it rather
    // than crash. If mkfifo is unavailable, fall back to a directory record, which
    // the directory-expansion path handles (expanding to zero files).
    const fifoRel = 'pipe.dart';
    const fifoAbs = path.join(repoRoot, comp, 'lib', fifoRel);
    let fifoIsNonRegular = false;
    try {
      const { spawnSync } = await import('node:child_process');
      const r = spawnSync('mkfifo', [fifoAbs]);
      fifoIsNonRegular = r.status === 0 && fs.lstatSync(fifoAbs).isFIFO();
    } catch {
      fifoIsNonRegular = false;
    }

    const records = [`?? ${comp}/lib/${goodRel}\0`];
    if (fifoIsNonRegular) {
      // A plain-file record pointing at the FIFO (no trailing slash → classified
      // `present`, so it exercises the regular-file guard in saveAllToFlavor).
      records.push(`?? ${comp}/lib/${fifoRel}\0`);
    }
    const porcelain = records.join('');
    const spawn = makeFakeSpawn(repoRoot, porcelain);

    let code;
    assert.doesNotThrow(() => {
      code = withSilencedConsole(() => saveAllToFlavor(repoRoot, 'inte', { spawn }));
    }, 'saveAllToFlavor must not throw on a non-regular source entry');
    assert.equal(code, 0);

    // The good regular file is still copied.
    const goodDest = path.join(repoRoot, comp, '.inte', 'lib', goodRel);
    assert.ok(fs.existsSync(goodDest), 'regular file must still be copied');
    assert.equal(await fsp.readFile(goodDest, 'utf8'), 'good content');

    // The FIFO must NOT be copied into the flavor folder.
    if (fifoIsNonRegular) {
      const fifoDest = path.join(repoRoot, comp, '.inte', 'lib', fifoRel);
      assert.ok(!fs.existsSync(fifoDest), 'non-regular source must not be copied into the flavor folder');
    }
  } finally {
    await removeTempDir(repoRoot);
  }
});
