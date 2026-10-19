// base-backup-gitignore.test.mjs
//
// Base-backup Git-exclusion smoke test (task 20.1).
//
// Feature: flavor-code-switching, Property 18: Base-backup directory is
// excluded from Git.
//
// Statically guards the Base_Backup_Directory exclusion guarantee: the
// repo-root `.gitignore` MUST cause Git to ignore the Base_Backup_Directory
// `.flavor-base-backup/` (and representative nested paths inside it), while
// representative base `lib/` `.dart` target paths remain NOT ignored (the
// manifest is intentionally ignored under the base-state policy — see
// gitignore-visibility.test.mjs). This is the complement of
// `scripts/test/gitignore-visibility.test.mjs`, and together they pin the
// `.gitignore` behavior against future edits.
//
// Validates: Requirements 10.6
//
// Two layers of assertion:
//
//   1. AUTHORITATIVE — ask Git directly via `git check-ignore -v --no-index`.
//      `git check-ignore` exits 0 when a path IS ignored (a match was found)
//      and 1 when it is NOT ignored. We assert exit 0 for backup-dir paths and
//      exit 1 for the base `lib/` targets. If git is unavailable (spawn
//      ENOENT) or the workspace is not a git repo (`check-ignore` exits 128),
//      the test SKIPs gracefully rather than failing — environment issues must
//      not produce a false failure.
//
//   2. ROBUST FALLBACK (always runs) — read the root `.gitignore` text and
//      assert it contains an entry that ignores the Base_Backup_Directory
//      (a line matching `/\.flavor-base-backup\/?/`). This is a light
//      assertion; layer 1 is authoritative.
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// This test lives at <repoRoot>/scripts/test/, so repoRoot is two levels up.
const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const gitignorePath = resolve(repoRoot, '.gitignore');

// Representative nested paths INSIDE the Base_Backup_Directory that MUST be
// ignored by Git (Req 10.6).
const IGNORED = [
  '.flavor-base-backup/sfera/lib/src/foo.dart',
  '.flavor-base-backup/x.dart',
];

// Paths that MUST stay visible to Git (complement — guards that the backup-dir
// rule does not over-match the base sources): a representative base `lib/`
// target using a plain `.dart` name. NOTE: `.flavor-manifest.json` is
// deliberately NOT here — the base-state policy (Req 9.1) makes the manifest
// a gitignored local-only artifact; its ignored-status is owned by
// gitignore-visibility.test.mjs.
const NOT_IGNORED = [
  'sfera/lib/src/flavor_example.dart',
];

function checkIgnore(path) {
  return spawnSync(
    'git',
    ['check-ignore', '-v', '--no-index', '--', path],
    { cwd: repoRoot, encoding: 'utf8' },
  );
}

test('git check-ignore: .flavor-base-backup/ is ignored while manifest + lib targets stay visible', (t) => {
  // Probe git availability + repo status with a representative candidate.
  const probe = checkIgnore(IGNORED[0]);

  // git binary not on PATH (ENOENT) or otherwise un-spawnable → skip.
  if (probe.error) {
    t.skip(`git is not available (${probe.error.code ?? probe.error.message}); skipping authoritative check`);
    return;
  }

  // Not a git repository → check-ignore reports a fatal error with code 128.
  if (probe.status === 128) {
    t.skip('workspace is not a git repository (git check-ignore exited 128); skipping authoritative check');
    return;
  }

  // Backup-dir paths MUST be ignored (exit 0 = a .gitignore rule matched).
  for (const candidate of IGNORED) {
    const result = checkIgnore(candidate);

    assert.equal(
      result.error,
      undefined,
      `git check-ignore must spawn cleanly for ${candidate}`,
    );
    assert.notEqual(
      result.status,
      128,
      `git check-ignore reported a fatal error for ${candidate}: ${result.stderr}`,
    );
    assert.equal(
      result.status,
      0,
      `.gitignore MUST ignore "${candidate}" (Req 10.6), but git check-ignore reported it NOT ignored`,
    );
  }

  // Base lib/ targets MUST NOT be ignored (exit 1 = no rule matched).
  for (const candidate of NOT_IGNORED) {
    const result = checkIgnore(candidate);

    assert.equal(
      result.error,
      undefined,
      `git check-ignore must spawn cleanly for ${candidate}`,
    );
    assert.notEqual(
      result.status,
      128,
      `git check-ignore reported a fatal error for ${candidate}: ${result.stderr}`,
    );
    assert.equal(
      result.status,
      1,
      `.gitignore must NOT ignore the base source "${candidate}" (Req 9.2), but git check-ignore reported it ignored` +
        (result.stdout ? ` via rule: ${result.stdout.trim()}` : ''),
    );
  }
});

test('.gitignore text contains an entry that ignores the base-backup directory (fallback)', () => {
  const contents = readFileSync(gitignorePath, 'utf8');

  const lines = contents
    .split(/\r?\n/)
    // Strip surrounding whitespace and drop comments/blank lines.
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith('#'));

  // At least one entry must reference the Base_Backup_Directory. Accept the
  // common forms: `.flavor-base-backup`, `.flavor-base-backup/`, and the
  // root-anchored `/.flavor-base-backup/` (what the repo currently uses).
  const backupEntry = /\.flavor-base-backup\/?/;
  const hasBackupRule = lines.some((line) => backupEntry.test(line));

  assert.equal(
    hasBackupRule,
    true,
    '.gitignore must contain an entry that ignores the Base_Backup_Directory ".flavor-base-backup/" (Req 10.6)',
  );
});
