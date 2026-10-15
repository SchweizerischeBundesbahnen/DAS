// usage.test.mjs
//
// Unit tests for the --help/-h usage output (task 13.1).
//
// Covers: usageText() is a non-empty string that mentions every flavor, the
// script invocation name, the --remove-dep option, and --help; and main() with
// --help returns 0 and prints the usage text to stdout without touching the
// filesystem.
//
// _Requirements: 6.1, 6.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { usageText, main, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir } from './helpers.mjs';

const NODE = '/usr/bin/node';
const SCRIPT = '/repo/scripts/switch-flavor.mjs';

/** Build an argv with the two required leading dummy entries. */
function argv(...rest) {
  return [NODE, SCRIPT, ...rest];
}

/** Run `fn` with console.log captured; returns the joined captured output. */
function captureLog(fn) {
  const original = console.log;
  const lines = [];
  console.log = (...parts) => {
    lines.push(parts.join(' '));
  };
  try {
    fn();
  } finally {
    console.log = original;
  }
  return lines.join('\n');
}

test('usageText() is a non-empty string', () => {
  const text = usageText();
  assert.equal(typeof text, 'string');
  assert.ok(text.trim().length > 0, 'usage text should not be empty');
});

test('usageText() mentions every flavor', () => {
  const text = usageText();
  for (const flavor of FLAVORS) {
    assert.ok(text.includes(flavor), `usage text should mention flavor '${flavor}'`);
  }
});

test('usageText() mentions the script name, --remove-dep, and --help', () => {
  const text = usageText();
  assert.ok(text.includes('switch-flavor.mjs'), 'usage text should name the script');
  assert.ok(text.includes('--remove-dep'), 'usage text should document --remove-dep');
  assert.ok(text.includes('--help'), 'usage text should document --help');
});

test('usageText() documents the --restore-base and --save-to-flavor modes', () => {
  const text = usageText();
  assert.ok(text.includes('--restore-base'), 'usage text should document --restore-base');
  assert.ok(text.includes('--save-to-flavor'), 'usage text should document --save-to-flavor');
});

test('usageText() documents the --all save-to-flavor modifier', () => {
  const text = usageText();
  assert.ok(text.includes('--all'), 'usage text should document --all');
});

test('usageText() summarizes the tool behavior and the manifest file', () => {
  const text = usageText();
  assert.ok(text.includes('lib/'), 'usage text should mention copying into lib/');
  assert.ok(
    text.includes('.flavor-manifest.json'),
    'usage text should mention the manifest file',
  );
});

test('main([..., --help]) returns 0 and prints the usage text', async () => {
  // --help must succeed without requiring a real repo, but we still pass a temp
  // dir as repoRoot to prove no filesystem access is needed to show help.
  const dir = await makeTempDir();
  try {
    let code;
    const output = captureLog(() => {
      code = main(argv('--help'), { repoRoot: dir });
    });
    assert.equal(code, 0);
    assert.equal(output, usageText());
  } finally {
    await removeTempDir(dir);
  }
});

test('main([..., -h]) returns 0 and prints the usage text', async () => {
  const dir = await makeTempDir();
  try {
    let code;
    const output = captureLog(() => {
      code = main(argv('-h'), { repoRoot: dir });
    });
    assert.equal(code, 0);
    assert.equal(output, usageText());
  } finally {
    await removeTempDir(dir);
  }
});
