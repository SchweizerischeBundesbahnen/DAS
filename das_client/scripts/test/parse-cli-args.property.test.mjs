// parse-cli-args.property.test.mjs
//
// Property test for parseCliArgs invalid-input handling.
//
// Feature: flavor-code-switching, Property 9: No mutation on invalid input
// (argument-level): for argv where the flavor positional is missing or is a
// value not in FLAVORS, parseCliArgs returns a validation error result
// ({ ok: false, error }) and never a valid parse result.
//
// Validates: Requirements 6.1, 6.2
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { parseCliArgs, FLAVORS } from '../switch-flavor.mjs';

const ITERATIONS = 200; // >= 100 minimum per the plan.

/** Simple seeded-free PRNG wrapper around Math.random for readability. */
function randInt(maxExclusive) {
  return Math.floor(Math.random() * maxExclusive);
}

/** Pick a random element of an array. */
function pick(arr) {
  return arr[randInt(arr.length)];
}

/**
 * Produce a random string that is NOT one of the valid flavors (and not a flag
 * / help token). Guarantees the positional, when present, is invalid.
 */
function randomNonFlavorString() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.';
  for (;;) {
    const len = 1 + randInt(12);
    let s = '';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    // Must not be a valid flavor and must not start with '-' (which would be
    // parsed as a flag, not a positional).
    if (!FLAVORS.includes(s) && !s.startsWith('-')) return s;
  }
}

/**
 * Build a random argv array exercising the invalid-input space:
 *   - sometimes no flavor positional at all, OR
 *   - a random non-flavor string positional.
 * Optionally appends `--remove-dep=<random>`.
 *
 * Two dummy leading entries (node binary, script path) match the parseArgs
 * slicing convention used by parseCliArgs.
 *
 * NOTE: --help / -h is intentionally never generated here, because
 * parseCliArgs short-circuits to ok:true when help is present.
 */
function generateInvalidArgv() {
  const argv = ['/usr/bin/node', '/repo/scripts/switch-flavor.mjs'];

  const missingFlavor = Math.random() < 0.4;
  if (!missingFlavor) {
    argv.push(randomNonFlavorString());
  }

  // Optionally add a --remove-dep flag with a random value.
  if (Math.random() < 0.5) {
    const dep = randomNonFlavorString();
    // Randomly use either the = form or the space-separated form.
    if (Math.random() < 0.5) {
      argv.push(`--remove-dep=${dep}`);
    } else {
      argv.push('--remove-dep', dep);
    }
  }

  return argv;
}

test('Property 9: parseCliArgs returns a validation error for missing/invalid flavor', () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const argv = generateInvalidArgv();
    const result = parseCliArgs(argv);

    const ctx = `argv=${JSON.stringify(argv)}`;

    // Must be a result object.
    assert.ok(result && typeof result === 'object', `result is an object (${ctx})`);

    // Must be a validation error, never a valid parse result.
    assert.equal(result.ok, false, `result.ok must be false (${ctx})`);
    assert.equal(
      typeof result.error,
      'string',
      `result.error must be a string (${ctx})`,
    );
    assert.ok(result.error.length > 0, `result.error must be non-empty (${ctx})`);

    // Never expose a parsed flavor on the error path.
    assert.equal(result.flavor, undefined, `error result exposes no flavor (${ctx})`);
  }
});
