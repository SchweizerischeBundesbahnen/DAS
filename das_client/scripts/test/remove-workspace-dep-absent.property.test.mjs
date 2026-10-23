// remove-workspace-dep-absent.property.test.mjs
//
// Property test for removeWorkspaceDep absent-package no-op behaviour.
//
// Feature: flavor-code-switching, Property 11: Absent package leaves pubspec
// unchanged: for any package name NOT present in the `# workspace packages`
// block, removeWorkspaceDep SHALL report not-found (and therefore the caller
// leaves the file byte-identical). Package names that appear ONLY outside the
// workspace block (e.g. under a `# https://pub.dev/...` group) are out of scope
// and must also be reported as not_found.
//
// Validates: Requirements 7.3
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { removeWorkspaceDep } from '../switch-flavor.mjs';

const ITERATIONS = 200; // >= 100 minimum per the plan.

/** Random integer in [0, maxExclusive). */
function randInt(maxExclusive) {
  return Math.floor(Math.random() * maxExclusive);
}

/** Random integer in [min, max]. */
function randIntRange(min, max) {
  return min + randInt(max - min + 1);
}

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 3, maxLen = 12) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/**
 * Build a set of unique names so no two entries collide and so a chosen
 * "absent" name is guaranteed not to appear anywhere already generated.
 * @param {number} count
 * @param {Set<string>} [taken] names already in use
 */
function uniqueNames(count, taken = new Set()) {
  const names = [];
  while (names.length < count) {
    const n = randomName();
    if (taken.has(n)) continue;
    taken.add(n);
    names.push(n);
  }
  return names;
}

/**
 * Return a fresh random name that is NOT in `taken` (and record it as taken).
 * @param {Set<string>} taken
 * @returns {string}
 */
function freshName(taken) {
  let n = randomName();
  while (taken.has(n)) n = randomName();
  taken.add(n);
  return n;
}

/** Pick a random element of an array. */
function pick(arr) {
  return arr[randInt(arr.length)];
}

/**
 * Synthesize a valid pubspec text with:
 *   - a `dependencies:` section opening with a flutter sdk block,
 *   - a `# workspace packages` comment followed by a randomly-sized set of
 *     unique workspace entries,
 *   - then random `# https://pub.dev/...` comment groups each with normal deps
 *     that live OUTSIDE the workspace block.
 *
 * Returns the text plus the workspace names and the pub.dev names so the caller
 * can probe both "never seen" and "outside the block" package names.
 *
 * @returns {{ text: string, workspacePkgs: string[], pubDevPkgs: string[], taken: Set<string> }}
 */
function generatePubspec() {
  const taken = new Set(['flutter']);
  const lines = [];

  // A header that varies to exercise byte-identity of unrelated lines.
  lines.push('name: das_client');
  lines.push('publish_to: none');
  lines.push('');
  lines.push('environment:');
  lines.push('  sdk: ^3.0.0');
  lines.push('');
  if (Math.random() < 0.5) {
    lines.push('resolution: workspace');
    lines.push('');
  }

  // dependencies: section with a flutter sdk block.
  lines.push('dependencies:');
  lines.push('  flutter:');
  lines.push('    sdk: flutter');
  lines.push('');

  // # workspace packages block (at least one entry present).
  const workspacePkgs = uniqueNames(randIntRange(1, 6), taken);
  lines.push('  # workspace packages');
  for (const pkg of workspacePkgs) {
    const version = Math.random() < 0.5 ? 'any' : '1.0.0';
    lines.push(`  ${pkg}: ${version}`);
  }

  // Random # https://pub.dev/... comment groups with normal deps that sit
  // OUTSIDE the workspace block (these names must still be not_found).
  const pubDevPkgs = [];
  const groupCount = randIntRange(0, 3);
  for (let g = 0; g < groupCount; g++) {
    lines.push('');
    const pubDeps = uniqueNames(randIntRange(1, 3), taken);
    for (const dep of pubDeps) {
      pubDevPkgs.push(dep);
      lines.push(`  # https://pub.dev/packages/${dep}`);
      const version = Math.random() < 0.5 ? 'any' : `^${randIntRange(1, 9)}.${randIntRange(0, 20)}.0`;
      lines.push(`  ${dep}: ${version}`);
    }
  }

  // Random trailing newline to vary end-of-file shape.
  if (Math.random() < 0.5) lines.push('');

  return { text: lines.join('\n'), workspacePkgs, pubDevPkgs, taken };
}

test('Property 11: a package never present in the pubspec is reported not_found and the text is unchanged', () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const { text, taken } = generatePubspec();

    // A random name verified not to appear anywhere in the generated pubspec.
    const absent = freshName(taken);

    const ctx = `absent='${absent}'\n--- pubspec ---\n${text}\n---------------`;

    // Extra safety: the name genuinely does not occur in the text at all.
    assert.ok(
      !new RegExp(`(^|\\s)${absent}\\b`).test(text),
      `generated absent name must not appear in the pubspec (${ctx})`,
    );

    const result = removeWorkspaceDep(text, absent);

    assert.ok(result && typeof result === 'object', `result is an object (${ctx})`);
    assert.deepEqual(
      result,
      { ok: false, reason: 'not_found' },
      `absent package must yield { ok: false, reason: 'not_found' } (${ctx})`,
    );
    // The function emits no text on not_found, so the caller leaves the file
    // byte-identical — assert nothing was handed back to write.
    assert.equal(result.text, undefined, `no text may be returned on not_found (${ctx})`);
  }
});

test('Property 11: a package present only OUTSIDE the workspace block is reported not_found', () => {
  let exercised = 0;
  for (let i = 0; i < ITERATIONS; i++) {
    const { text, pubDevPkgs } = generatePubspec();

    // Only exercise iterations that actually produced a pub.dev dependency; the
    // workspace block never contains these names (uniqueNames keeps them
    // disjoint), so they are out of scope for removal.
    if (pubDevPkgs.length === 0) continue;
    exercised++;

    const outside = pick(pubDevPkgs);
    const ctx = `outside='${outside}'\n--- pubspec ---\n${text}\n---------------`;

    const result = removeWorkspaceDep(text, outside);

    assert.ok(result && typeof result === 'object', `result is an object (${ctx})`);
    assert.deepEqual(
      result,
      { ok: false, reason: 'not_found' },
      `pub.dev package outside the workspace block must be not_found (${ctx})`,
    );
    assert.equal(result.text, undefined, `no text may be returned on not_found (${ctx})`);
  }

  // Guard against a vacuous pass: ensure we really probed out-of-block names.
  assert.ok(exercised > 0, 'expected at least one iteration with a pub.dev dependency');
}
);
