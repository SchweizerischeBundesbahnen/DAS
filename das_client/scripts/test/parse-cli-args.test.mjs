// parse-cli-args.test.mjs
//
// Example/unit tests for parseCliArgs (task 2.3).
//
// Covers: each valid flavor dispatches to a successful parse result;
// `--remove-dep=<pkg>` is captured; `--help`/`-h` are recognized and
// short-circuit the flavor requirement; missing/invalid flavor return the
// expected validation error messages.
//
// _Requirements: 1.1, 6.1, 6.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { parseCliArgs, FLAVORS } from '../switch-flavor.mjs';

// parseCliArgs uses argv.slice(2), so every argv needs two leading dummy
// entries standing in for the node binary and the script path.
const NODE = '/usr/bin/node';
const SCRIPT = '/repo/scripts/switch-flavor.mjs';

/** Build an argv with the two required leading dummy entries. */
function argv(...rest) {
  return [NODE, SCRIPT, ...rest];
}

test('each valid flavor parses to a successful result', () => {
  for (const flavor of FLAVORS) {
    const result = parseCliArgs(argv(flavor));
    assert.deepEqual(result, {
      ok: true,
      flavor,
      removeDep: undefined,
      restoreBase: false,
      saveToFlavor: undefined,
      help: false,
      dryRun: false,
    });
  }
});

test('FLAVORS contains exactly dev, inte, prod', () => {
  // Guards the assumption behind the per-flavor dispatch test above.
  assert.deepEqual(FLAVORS, ['dev', 'inte', 'prod']);
});

test('--remove-dep=<pkg> is captured in removeDep (= form)', () => {
  const result = parseCliArgs(argv('dev', '--remove-dep=sfera_mock'));
  assert.deepEqual(result, {
    ok: true,
    flavor: 'dev',
    removeDep: 'sfera_mock',
    restoreBase: false,
    saveToFlavor: undefined,
    help: false,
    dryRun: false,
  });
});

test('--remove-dep <pkg> is captured in removeDep (space form)', () => {
  const result = parseCliArgs(argv('prod', '--remove-dep', 'sfera_mock'));
  assert.deepEqual(result, {
    ok: true,
    flavor: 'prod',
    removeDep: 'sfera_mock',
    restoreBase: false,
    saveToFlavor: undefined,
    help: false,
    dryRun: false,
  });
});

test('--help is recognized and short-circuits the flavor requirement', () => {
  const result = parseCliArgs(argv('--help'));
  assert.equal(result.ok, true);
  assert.equal(result.help, true);
  // No flavor supplied, yet still ok because help short-circuits validation.
  assert.equal(result.flavor, undefined);
});

test('-h is recognized and short-circuits the flavor requirement', () => {
  const result = parseCliArgs(argv('-h'));
  assert.equal(result.ok, true);
  assert.equal(result.help, true);
  assert.equal(result.flavor, undefined);
});

test('--help with a flavor still succeeds and carries the flavor', () => {
  const result = parseCliArgs(argv('inte', '--help'));
  assert.deepEqual(result, {
    ok: true,
    flavor: 'inte',
    removeDep: undefined,
    restoreBase: false,
    saveToFlavor: undefined,
    help: true,
    dryRun: false,
  });
});

test('missing flavor returns the required-parameter error', () => {
  const result = parseCliArgs(argv());
  assert.deepEqual(result, {
    ok: false,
    error: 'A flavor parameter is required',
  });
});

test('invalid flavor returns the not-a-valid-flavor error', () => {
  const result = parseCliArgs(argv('staging'));
  assert.deepEqual(result, {
    ok: false,
    error: "Not a valid flavor: 'staging' (expected dev|inte|prod)",
  });
});
