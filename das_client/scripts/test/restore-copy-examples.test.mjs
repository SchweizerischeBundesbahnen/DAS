// restore-copy-examples.test.mjs
//
// Example/unit tests for discrete restore-base and save-to-flavor cases (task 17.7).
//
// Deterministic examples (node:test + node:assert) against temp-dir fixtures,
// complementing the property tests in restore-roundtrip / save-to-flavor:
//
//   1. restoreBase tolerance of a single missing Base_Backup_File (Req 11.6):
//      a VALID manifest with two overwritten base files, one backup deleted →
//      restoreBase restores the surviving file, clears the manifest, removes the
//      backup dir, returns 0, and never throws.
//   2. saveToFlavor "destination overwritten" report on an existing dest
//      (Req 12.4): a pre-existing, different-content destination is overwritten
//      with the source content and the overwrite is reported to stdout.
//   3. readManifest v1 manifest → CORRUPT (Req 4.2): a v1-shaped manifest
//      (version 1, string[] files) is rejected (no v1→v2 migration).
//   4. saveToFlavor leaves the source in place on success (Req 12.3 nicety).
//
// _Requirements: 11.6, 12.4, 4.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`. Each test
// uses a fresh temp dir, silences console output, and tears the dir down
// afterwards (even on failure).

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

import {
  restoreBase,
  saveToFlavor,
  main,
  readManifest,
  FLAVORS,
  MANIFEST_VERSION,
  BASE_BACKUP_DIRNAME,
  MANIFEST_FILENAME,
} from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

/**
 * Run `fn` with a fresh temp dir, silencing console.log/console.error for the
 * duration and collecting whatever was written. Restores the originals and
 * tears the temp dir down afterwards, even on failure.
 *
 * @template T
 * @param {(ctx: { repoRoot: string, stdout: string[], stderr: string[] }) => Promise<T>} fn
 * @returns {Promise<T>}
 */
async function withSilencedRepo(fn) {
  const dir = await makeTempDir();
  const stdout = [];
  const stderr = [];
  const origLog = console.log;
  const origError = console.error;
  console.log = (...args) => stdout.push(args.map((a) => String(a)).join(' '));
  console.error = (...args) => stderr.push(args.map((a) => String(a)).join(' '));
  try {
    return await fn({ repoRoot: dir, stdout, stderr });
  } finally {
    console.log = origLog;
    console.error = origError;
    await removeTempDir(dir);
  }
}

/** Build argv in the shape main() expects: node, script, ...rest. */
function argv(...rest) {
  return ['node', 'switch-flavor.mjs', ...rest];
}

// ---------------------------------------------------------------------------
// 1. restoreBase tolerates a single missing Base_Backup_File (Req 11.6)
// ---------------------------------------------------------------------------

test('restoreBase tolerates one missing Base_Backup_File: restores the rest, clears state, returns 0 (Req 11.6)', async () => {
  await withSilencedRepo(async ({ repoRoot }) => {
    // Base state: two pre-existing lib/ files that the dev flavor will overwrite.
    const baseA = 'BASE A\n';
    const baseB = 'BASE B\n';
    await buildRepo(repoRoot, {
      components: [
        {
          name: 'sfera',
          lib: { 'a.dart': baseA, 'b.dart': baseB },
          // NEW layout: flavor files live under `.<flavor>/lib/...` (the flavor
          // folder mirrors the package root), so a switch copies them into lib/.
          flavors: { dev: { 'lib/a.dart': 'DEV A\n', 'lib/b.dart': 'DEV B\n' } },
        },
      ],
    });

    // Switch to dev: overwrites both base files and backs them up first.
    const switchCode = main(argv('dev'), { repoRoot });
    assert.equal(switchCode, 0, 'switch to dev should succeed');

    const libA = path.join(repoRoot, 'sfera', 'lib', 'a.dart');
    const libB = path.join(repoRoot, 'sfera', 'lib', 'b.dart');
    const backupDir = path.join(repoRoot, BASE_BACKUP_DIRNAME);
    const backupA = path.join(backupDir, 'sfera', 'lib', 'a.dart');
    const backupB = path.join(backupDir, 'sfera', 'lib', 'b.dart');

    // Sanity: both files now hold dev content and both backups exist.
    assert.equal(fs.readFileSync(libA, 'utf8'), 'DEV A\n');
    assert.equal(fs.readFileSync(libB, 'utf8'), 'DEV B\n');
    assert.ok(fs.existsSync(backupA), 'backup for a.dart should exist');
    assert.ok(fs.existsSync(backupB), 'backup for b.dart should exist');

    // Delete ONE Base_Backup_File — a.dart can no longer be restored.
    fs.rmSync(backupA);

    // Restore must tolerate the missing backup gracefully (no throw) and return 0.
    let code;
    assert.doesNotThrow(() => {
      code = restoreBase(repoRoot);
    });
    assert.equal(code, 0, 'restoreBase should return 0 despite the missing backup');

    // The OTHER overwritten file is restored to its original base content.
    assert.equal(fs.readFileSync(libB, 'utf8'), baseB, 'b.dart restored to base');
    // The file whose backup was deleted cannot be restored; it keeps dev content.
    assert.equal(
      fs.readFileSync(libA, 'utf8'),
      'DEV A\n',
      'a.dart (backup deleted) is left as-is, not restored',
    );

    // Bookkeeping is cleared: manifest removed and backup dir gone.
    assert.ok(
      !fs.existsSync(path.join(repoRoot, MANIFEST_FILENAME)),
      'manifest should be cleared',
    );
    assert.ok(!fs.existsSync(backupDir), 'base-backup dir should be removed');
  });
});

// ---------------------------------------------------------------------------
// 2. saveToFlavor reports "overwritten" on a pre-existing destination (Req 12.4)
// ---------------------------------------------------------------------------

test('saveToFlavor overwrites an existing destination and reports the overwrite (Req 12.4)', async () => {
  await withSilencedRepo(async ({ repoRoot, stdout }) => {
    const sourceContent = 'SOURCE CONTENT\n';
    const preExistingDest = 'OLD DESTINATION CONTENT\n';
    const flavor = 'dev';
    const srcRel = 'sfera/lib/src/foo.dart';
    // NEW layout: destination keeps the `lib/` root segment after `.<flavor>`.
    const destRel = 'sfera/.dev/lib/src/foo.dart';

    await buildRepo(repoRoot, {
      components: [
        {
          name: 'sfera',
          lib: { 'src/foo.dart': sourceContent },
          // Pre-existing, DIFFERENT-content file at the flavor destination
          // (under the `lib/` root, mirroring the package root).
          flavors: { dev: { 'lib/src/foo.dart': preExistingDest } },
        },
      ],
    });

    const destAbs = path.join(repoRoot, 'sfera', '.dev', 'lib', 'src', 'foo.dart');
    assert.equal(
      fs.readFileSync(destAbs, 'utf8'),
      preExistingDest,
      'destination pre-exists with different content',
    );

    const code = saveToFlavor(repoRoot, flavor, srcRel);
    assert.equal(code, 0, 'saveToFlavor should succeed');

    // Destination now holds the source content.
    assert.equal(
      fs.readFileSync(destAbs, 'utf8'),
      sourceContent,
      'destination overwritten with source content',
    );

    // A stdout line reports the destination was overwritten.
    const reportedOverwrite = stdout.some((line) => /overwrote|overwritten/i.test(line));
    assert.ok(
      reportedOverwrite,
      `expected an overwrite report on stdout; got: ${JSON.stringify(stdout)}`,
    );

    // The destination path is referenced in the report.
    assert.ok(
      stdout.some((line) => line.includes(destRel)),
      `expected the destination path in the report; got: ${JSON.stringify(stdout)}`,
    );
  });
});

// ---------------------------------------------------------------------------
// 3. readManifest classifies a v1-shaped manifest as CORRUPT (Req 4.2)
// ---------------------------------------------------------------------------

test('readManifest classifies a v1 manifest (version 1, string[] files) as CORRUPT (Req 4.2)', async () => {
  await withSilencedRepo(async ({ repoRoot }) => {
    // A surviving v1 manifest: there is deliberately no v1→v2 migration, so it
    // routes to the safe copy-only path (CORRUPT).
    await buildRepo(repoRoot, {
      manifest: { version: 1, flavor: 'dev', files: ['a/lib/x.dart'] },
    });

    assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    // Guard the fixture against a silently-bumped MANIFEST_VERSION constant.
    assert.notEqual(1, MANIFEST_VERSION, 'v1 is older than the current schema');
    assert.ok(FLAVORS.includes('dev'), 'dev is a valid flavor; version is why it is CORRUPT');
  });
});

// ---------------------------------------------------------------------------
// 4. saveToFlavor leaves the source in place on a successful copy (Req 12.3)
// ---------------------------------------------------------------------------

test('saveToFlavor leaves the source lib/ file in place after a successful copy (Req 12.3)', async () => {
  await withSilencedRepo(async ({ repoRoot }) => {
    const sourceContent = 'KEEP ME\n';
    const srcRel = 'sfera/lib/src/bar.dart';

    await buildRepo(repoRoot, {
      components: [{ name: 'sfera', lib: { 'src/bar.dart': sourceContent } }],
    });

    const srcAbs = path.join(repoRoot, 'sfera', 'lib', 'src', 'bar.dart');

    const code = saveToFlavor(repoRoot, 'inte', srcRel);
    assert.equal(code, 0, 'saveToFlavor should succeed');

    // Source still exists with identical content (it is a COPY, not a move).
    assert.ok(fs.existsSync(srcAbs), 'source lib/ file should still exist');
    assert.equal(fs.readFileSync(srcAbs, 'utf8'), sourceContent, 'source content unchanged');

    // And the copy landed at the derived flavor destination (NEW layout keeps
    // the `lib/` root segment after `.<flavor>`).
    const destAbs = path.join(repoRoot, 'sfera', '.inte', 'lib', 'src', 'bar.dart');
    assert.equal(fs.readFileSync(destAbs, 'utf8'), sourceContent, 'copy produced at flavor dest');
  });
});
