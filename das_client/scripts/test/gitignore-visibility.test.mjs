// gitignore-visibility.test.mjs
//
// Git-visibility smoke test (task 12.1, revised).
//
// Repo policy: the repository always stays on the BASE state. The active-flavor
// manifest (`.flavor-manifest.json`) is a LOCAL-ONLY artifact and MUST be
// ignored by Git so a switched manifest is never committed. At the same time the
// base code under `lib/` MUST remain visible to Git (a switch overwrites `lib/`
// with flavor code only locally; the committed tree is the base).
//
// This supersedes the earlier "manifest must be visible" guarantee: see the
// updated Requirement 9 (Base State Is the Committed State) in requirements.md.
//
// _Requirements: 9.1, 9.2, 9.3_
//
// Two layers of assertion:
//
//   1. AUTHORITATIVE — ask Git directly via `git check-ignore -v --no-index`.
//      `git check-ignore` exits 0 when a path IS ignored and 1 when it is NOT.
//      We assert the manifest IS ignored (exit 0) and that representative `lib/`
//      `.dart` targets are NOT ignored (exit 1). If git is unavailable (spawn
//      ENOENT) or the workspace is not a git repo (exit 128), the test SKIPs
//      gracefully rather than failing — environment issues must not fail CI.
//
//   2. ROBUST FALLBACK (always runs) — read the root `.gitignore` text and
//      assert it DOES contain an entry that ignores `.flavor-manifest.json`,
//      and contains no root-scope `*.json` sweep that would also hide unrelated
//      JSON. This is a light assertion; layer 1 is authoritative.
//
// Design caveat: `.gitignore` DOES ignore generated patterns like `*.g.dart`,
// `*.gr.dart`, `*.freezed.dart`, `*.mocks.dart`. Flavor source files are plain
// `.dart` sources (not generated-file names), so the representative targets
// below use plain names like `flavor_example.dart` — never a `*.g.dart`-style
// name.
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

// The manifest is a local-only artifact that MUST be ignored.
const MANIFEST = '.flavor-manifest.json';

// Representative switched `lib/` targets (plain `.dart` names, not generated
// patterns) that MUST stay visible to Git so the base tree is committable.
const VISIBLE_TARGETS = [
  'sfera/lib/src/flavor_example.dart',
  'app/lib/flavor_example.dart',
];

/** Run `git check-ignore` for a path; returns the spawn result. */
function checkIgnore(candidate) {
  return spawnSync(
    'git',
    ['check-ignore', '-v', '--no-index', '--', candidate],
    { cwd: repoRoot, encoding: 'utf8' },
  );
}

test('git check-ignore: the manifest is ignored, lib/ targets are not', (t) => {
  // Probe git availability + repo status with the manifest candidate.
  const probe = checkIgnore(MANIFEST);

  if (probe.error) {
    t.skip(`git is not available (${probe.error.code ?? probe.error.message}); skipping authoritative check`);
    return;
  }
  if (probe.status === 128) {
    t.skip('workspace is not a git repository (git check-ignore exited 128); skipping authoritative check');
    return;
  }

  // The manifest MUST be ignored → check-ignore exits 0 (a rule matched).
  assert.equal(
    probe.status,
    0,
    `.gitignore MUST ignore "${MANIFEST}" so a switched manifest is never committed (Req 9.1)` +
      (probe.stdout ? ` — matched rule: ${probe.stdout.trim()}` : `, but git check-ignore reported it NOT ignored`),
  );

  // The base `lib/` targets MUST remain visible → check-ignore exits 1.
  for (const candidate of VISIBLE_TARGETS) {
    const result = checkIgnore(candidate);
    assert.equal(result.error, undefined, `git check-ignore must spawn cleanly for ${candidate}`);
    assert.notEqual(
      result.status,
      128,
      `git check-ignore reported a fatal error for ${candidate}: ${result.stderr}`,
    );
    assert.equal(
      result.status,
      1,
      `.gitignore must NOT ignore the base target "${candidate}" (Req 9.2)` +
        (result.stdout ? ` via rule: ${result.stdout.trim()}` : ''),
    );
  }
});

test('.gitignore text ignores the manifest without a root-scope *.json sweep (fallback)', () => {
  const contents = readFileSync(gitignorePath, 'utf8');

  const lines = contents
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith('#'));

  // An entry that ignores the repo-root manifest must be present (either the
  // bare name or the root-anchored form).
  assert.ok(
    lines.includes('.flavor-manifest.json') || lines.includes('/.flavor-manifest.json'),
    '.gitignore must contain a ".flavor-manifest.json" (or "/.flavor-manifest.json") entry (Req 9.1)',
  );

  // But NOT via a broad root-scope "*.json" sweep that would also hide unrelated
  // JSON files.
  assert.equal(
    lines.includes('*.json'),
    false,
    '.gitignore must not ignore the manifest via a broad root-scope "*.json" entry',
  );
  assert.equal(
    lines.includes('/*.json'),
    false,
    '.gitignore must not ignore the manifest via a broad root-scope "/*.json" entry',
  );
});
