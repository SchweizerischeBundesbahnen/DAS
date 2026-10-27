// remove-workspace-dep.property.test.mjs
//
// Property test for removeWorkspaceDep structure-preserving removal.
//
// Feature: flavor-code-switching, Property 10: Structure-preserving dependency
// removal: for any pubspec.yaml containing a given workspace package in the
// `# workspace packages` block, removing that package deletes exactly the one
// line declaring it, leaves every other line (comments, blank lines, remaining
// entries) byte-identical, and the removed key is absent from the parsed
// dependencies.
//
// Validates: Requirements 7.1, 7.2
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

/** Pick a random element of an array. */
function pick(arr) {
  return arr[randInt(arr.length)];
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
 * Build a set of unique names so no two entries collide (which would make the
 * "exactly one line" expectation ambiguous).
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
 * Synthesize a valid pubspec text:
 *   - a `dependencies:` section opening with a flutter sdk block,
 *   - a `# workspace packages` comment followed by a randomly-sized set of
 *     workspace entries (`<name>: 1.0.0` or `any`),
 *   - then random `# https://pub.dev/...` comment groups each with normal deps.
 *
 * Returns the text plus the list of workspace package names so the caller can
 * pick a random one to remove.
 *
 * @returns {{ text: string, workspacePkgs: string[] }}
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

  // # workspace packages block (at least one, so there is something to remove).
  const workspacePkgs = uniqueNames(randIntRange(1, 6), taken);
  lines.push('  # workspace packages');
  for (const pkg of workspacePkgs) {
    const version = Math.random() < 0.5 ? 'any' : '1.0.0';
    lines.push(`  ${pkg}: ${version}`);
  }

  // Random # https://pub.dev/... comment groups with normal deps.
  const groupCount = randIntRange(0, 3);
  for (let g = 0; g < groupCount; g++) {
    lines.push('');
    const pubDeps = uniqueNames(randIntRange(1, 3), taken);
    for (const dep of pubDeps) {
      lines.push(`  # https://pub.dev/packages/${dep}`);
      const version = Math.random() < 0.5 ? 'any' : `^${randIntRange(1, 9)}.${randIntRange(0, 20)}.0`;
      lines.push(`  ${dep}: ${version}`);
    }
  }

  // Random trailing newline to vary end-of-file shape.
  if (Math.random() < 0.5) lines.push('');

  return { text: lines.join('\n'), workspacePkgs };
}

/**
 * Compute the expected output by splicing out exactly the one line that
 * declares `pkg` (the `  <pkg>: ...` line). Independent of the implementation.
 * @param {string} text
 * @param {string} pkg
 * @returns {string}
 */
function spliceOutPkgLine(text, pkg) {
  const lines = text.split('\n');
  const re = new RegExp(`^\\s*${pkg}:`);
  let removedCount = 0;
  const kept = lines.filter((line) => {
    if (re.test(line)) {
      removedCount++;
      return false;
    }
    return true;
  });
  assert.equal(
    removedCount,
    1,
    `expected exactly one declaring line for '${pkg}' in the generated pubspec`,
  );
  return kept.join('\n');
}

test('Property 10: removeWorkspaceDep removes exactly one line, leaving the rest byte-identical', () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const { text, workspacePkgs } = generatePubspec();
    const pkg = pick(workspacePkgs);

    const ctx = `pkg='${pkg}'\n--- pubspec ---\n${text}\n---------------`;

    const result = removeWorkspaceDep(text, pkg);

    // Must succeed for a package that is present in the block.
    assert.ok(result && typeof result === 'object', `result is an object (${ctx})`);
    assert.equal(result.ok, true, `result.ok must be true (${ctx})`);
    assert.equal(typeof result.text, 'string', `result.text must be a string (${ctx})`);

    // Byte-for-byte: output equals input with exactly the one declaring line
    // spliced out.
    const expected = spliceOutPkgLine(text, pkg);
    assert.equal(result.text, expected, `output must equal input minus one line (${ctx})`);

    // Line count decreased by exactly 1.
    const beforeLines = text.split('\n').length;
    const afterLines = result.text.split('\n').length;
    assert.equal(
      afterLines,
      beforeLines - 1,
      `line count must decrease by exactly 1 (before=${beforeLines}, after=${afterLines}) (${ctx})`,
    );

    // Re-running on the output for the same pkg reports not_found.
    const second = removeWorkspaceDep(result.text, pkg);
    assert.ok(second && typeof second === 'object', `second result is an object (${ctx})`);
    assert.equal(second.ok, false, `second removal must not succeed (${ctx})`);
    assert.equal(
      second.reason,
      'not_found',
      `second removal reason must be 'not_found' (${ctx})`,
    );
  }
});
