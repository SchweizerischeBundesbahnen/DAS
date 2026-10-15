// remove-workspace-dep-real.test.mjs
//
// Example/unit tests for removeWorkspaceDep (task 4.4) against the REAL
// `app/pubspec.yaml` text.
//
// Covers:
//   - Removing a middle workspace package ("warnapp") removes exactly that one
//     line; every other line — including the `# https://pub.dev/...` comments
//     and other workspace entries like "sfera" — survives byte-identical and in
//     order; result.ok === true.
//   - Removing the first workspace entry ("app_links_x") works cleanly.
//   - A package not in the workspace block ("nonexistent_pkg") returns
//     { ok:false, reason:'not_found' }.
//   - A dependency that exists OUTSIDE the workspace block ("audioplayers",
//     under its own pub.dev comment group) returns { ok:false,
//     reason:'not_found' } because only the workspace block is in scope.
//
// _Requirements: 7.1, 7.2, 7.3_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { removeWorkspaceDep } from '../switch-flavor.mjs';

// Resolve the real app pubspec relative to THIS test file (never hardcode an
// absolute path). test file lives at <repoRoot>/scripts/test/, so the pubspec is
// at ../../app/pubspec.yaml.
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PUBSPEC_PATH = path.resolve(__dirname, '..', '..', 'app', 'pubspec.yaml');
const PUBSPEC_TEXT = fs.readFileSync(PUBSPEC_PATH, 'utf8');

/**
 * Diff two texts line-by-line, asserting that `after` equals `before` with
 * exactly the one declaring line for `pkg` removed and every other line
 * byte-identical and in the same order.
 *
 * @param {string} before
 * @param {string} after
 * @param {string} pkg
 */
function assertExactlyOneLineRemoved(before, after, pkg) {
  const beforeLines = before.split('\n');
  const afterLines = after.split('\n');

  assert.equal(
    afterLines.length,
    beforeLines.length - 1,
    `line count must decrease by exactly 1 (before=${beforeLines.length}, after=${afterLines.length})`,
  );

  // Find the single declaring line in the original.
  const re = new RegExp(`^\\s*${pkg}:`);
  const removedIndices = beforeLines
    .map((line, idx) => (re.test(line) ? idx : -1))
    .filter((idx) => idx !== -1);
  assert.equal(
    removedIndices.length,
    1,
    `expected exactly one declaring line for '${pkg}' in the real pubspec`,
  );
  const removedIdx = removedIndices[0];

  // Every line before the removed index must be byte-identical.
  for (let i = 0; i < removedIdx; i++) {
    assert.equal(
      afterLines[i],
      beforeLines[i],
      `line ${i} must survive byte-identical (before the removed line)`,
    );
  }
  // Every line after the removed index shifts up by one and must be identical.
  for (let i = removedIdx + 1; i < beforeLines.length; i++) {
    assert.equal(
      afterLines[i - 1],
      beforeLines[i],
      `line ${i} must survive byte-identical (after the removed line)`,
    );
  }
}

test('removing a middle workspace package ("warnapp") removes exactly that line', () => {
  const result = removeWorkspaceDep(PUBSPEC_TEXT, 'warnapp');

  assert.equal(result.ok, true, 'result.ok must be true for a present workspace pkg');
  assert.equal(typeof result.text, 'string', 'result.text must be a string');

  assertExactlyOneLineRemoved(PUBSPEC_TEXT, result.text, 'warnapp');

  // The removed line is gone.
  assert.equal(
    /^\s*warnapp:/m.test(result.text),
    false,
    'the warnapp declaration must be absent from the output',
  );

  // A sibling workspace entry survives.
  assert.equal(
    /^\s*sfera: 1\.0\.0$/m.test(result.text),
    true,
    'the sfera workspace entry must survive unchanged',
  );

  // The `# https://pub.dev/...` comment group survives (sample a few).
  assert.ok(
    result.text.includes('# https://pub.dev/packages/audioplayers'),
    'the audioplayers pub.dev comment must survive',
  );
  assert.ok(
    result.text.includes('# https://pub.dev/packages/url_launcher'),
    'the url_launcher pub.dev comment must survive',
  );

  // The `# workspace packages` marker survives.
  assert.ok(
    result.text.includes('# workspace packages'),
    'the workspace packages marker comment must survive',
  );
});

test('removing the first workspace entry ("app_links_x") works cleanly', () => {
  const result = removeWorkspaceDep(PUBSPEC_TEXT, 'app_links_x');

  assert.equal(result.ok, true, 'result.ok must be true for the first workspace pkg');
  assert.equal(typeof result.text, 'string', 'result.text must be a string');

  assertExactlyOneLineRemoved(PUBSPEC_TEXT, result.text, 'app_links_x');

  // The removed line is gone.
  assert.equal(
    /^\s*app_links_x:/m.test(result.text),
    false,
    'the app_links_x declaration must be absent from the output',
  );

  // The next workspace entry ("auth") immediately follows the marker now.
  assert.ok(
    /# workspace packages\n\s*auth: 1\.0\.0/.test(result.text),
    'the second workspace entry (auth) must directly follow the marker',
  );

  // The marker comment survives.
  assert.ok(
    result.text.includes('# workspace packages'),
    'the workspace packages marker comment must survive',
  );
});

test('a package absent from the workspace block ("nonexistent_pkg") returns not_found', () => {
  const result = removeWorkspaceDep(PUBSPEC_TEXT, 'nonexistent_pkg');

  assert.equal(result.ok, false, 'result.ok must be false for an absent package');
  assert.equal(result.reason, 'not_found', "reason must be 'not_found'");
});

test('a dependency outside the workspace block ("audioplayers") returns not_found', () => {
  // audioplayers exists in pubspec, but under its own `# https://pub.dev/...`
  // comment group — outside the `# workspace packages` block, so it is out of
  // scope for removeWorkspaceDep.
  assert.ok(
    /^\s*audioplayers:/m.test(PUBSPEC_TEXT),
    'precondition: audioplayers must exist in the real pubspec',
  );

  const result = removeWorkspaceDep(PUBSPEC_TEXT, 'audioplayers');

  assert.equal(result.ok, false, 'result.ok must be false for an out-of-block dependency');
  assert.equal(result.reason, 'not_found', "reason must be 'not_found'");
});
