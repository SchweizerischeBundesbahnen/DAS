// gitignore-visibility.test.mjs
//
// Git-visibility smoke test (task 12.1).
//
// Statically guards the Git-visibility guarantee: the repo-root `.gitignore`
// must NOT cause Git to ignore `.flavor-manifest.json` or representative `lib/`
// `.dart` target paths produced by a flavor switch. This protects Requirement
// 9.1 against future `.gitignore` edits.
//
// _Requirements: 9.1_
//
// Two layers of assertion:
//
//   1. AUTHORITATIVE — ask Git directly via `git check-ignore -v --no-index`.
//      `git check-ignore` exits 0 when a path IS ignored (a match was found)
//      and 1 when it is NOT ignored. We assert exit code === 1 for every
//      candidate. If git is unavailable (spawn ENOENT) or the workspace is not
//      a git repo (`check-ignore` exits 128), the test SKIPs gracefully rather
//      than failing — environment issues must not produce a false failure.
//
//   2. ROBUST FALLBACK (always runs) — read the root `.gitignore` text and
//      assert it contains no line that would ignore `.flavor-manifest.json`
//      exactly (no bare `.flavor-manifest.json` entry and no root-scope
//      `*.json` entry). This is a light assertion; layer 1 is authoritative.
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

// Candidate paths that a flavor switch produces and that MUST stay visible to
// Git: the manifest at the repo root, plus representative switched `lib/`
// targets using plain `.dart` names (not generated-file patterns).
const CANDIDATES = [
  '.flavor-manifest.json',
  'sfera/lib/src/flavor_example.dart',
  'app/lib/flavor_example.dart',
];

test('git check-ignore: no flavor target path is ignored by .gitignore', (t) => {
  // Probe git availability + repo status with a representative candidate.
  const probe = spawnSync(
    'git',
    ['check-ignore', '-v', '--no-index', '--', CANDIDATES[0]],
    { cwd: repoRoot, encoding: 'utf8' },
  );

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

  for (const candidate of CANDIDATES) {
    const result = spawnSync(
      'git',
      ['check-ignore', '-v', '--no-index', '--', candidate],
      { cwd: repoRoot, encoding: 'utf8' },
    );

    assert.equal(
      result.error,
      undefined,
      `git check-ignore must spawn cleanly for ${candidate}`,
    );

    // Guard against a non-repo / fatal error surfacing per-candidate too.
    assert.notEqual(
      result.status,
      128,
      `git check-ignore reported a fatal error for ${candidate}: ${result.stderr}`,
    );

    // Exit 0 means a .gitignore rule matched (path IS ignored) — a failure of
    // the Git-visibility guarantee. The matching rule is printed on stdout by
    // the -v flag, surfaced here for actionable diagnostics.
    assert.equal(
      result.status,
      1,
      `.gitignore must NOT ignore "${candidate}" (Req 9.1), but git check-ignore reported it ignored` +
        (result.stdout ? ` via rule: ${result.stdout.trim()}` : ''),
    );
  }
});

test('.gitignore text contains no entry that would ignore .flavor-manifest.json (fallback)', () => {
  const contents = readFileSync(gitignorePath, 'utf8');

  const lines = contents
    .split(/\r?\n/)
    // Strip surrounding whitespace and drop comments/blank lines.
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith('#'));

  // No bare entry matching the manifest file name exactly.
  assert.equal(
    lines.includes('.flavor-manifest.json'),
    false,
    '.gitignore must not contain an exact ".flavor-manifest.json" entry (Req 9.1)',
  );
  assert.equal(
    lines.includes('/.flavor-manifest.json'),
    false,
    '.gitignore must not contain an exact "/.flavor-manifest.json" entry (Req 9.1)',
  );

  // No root-scope "*.json" entry, which would sweep up the manifest. A nested
  // pattern like "foo/*.json" is scoped elsewhere and does not match the
  // repo-root manifest, so only root-scope forms are rejected here.
  assert.equal(
    lines.includes('*.json'),
    false,
    '.gitignore must not contain a root-scope "*.json" entry (Req 9.1)',
  );
  assert.equal(
    lines.includes('/*.json'),
    false,
    '.gitignore must not contain a root-scope "/*.json" entry (Req 9.1)',
  );
});
