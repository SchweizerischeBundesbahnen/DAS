// save-to-flavor.property.test.mjs
//
// Property test for saveToFlavor copy fidelity and source preservation.
//
// Feature: flavor-code-switching, Property 16: Copy-to-flavor fidelity and
// source preservation: for any existing <component>/lib/<rest> file and valid
// flavor, saveToFlavor leaves the source byte-identical under lib/ (it is a COPY,
// not a move) and produces a byte-identical copy at <component>/<flavor>/<rest>,
// whether or not a file already existed at the destination (the pre-existing
// destination is overwritten with the source content).
//
// Validates: Requirements 12.1, 12.2, 12.3, 12.4
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveToFlavor, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

const ITERATIONS = 150; // >= 100 minimum per the plan.

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
function randomName(minLen = 1, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content — may include non-ASCII bytes and newlines. */
function randomContent() {
  const kind = randInt(3);
  if (kind === 0) return ''; // empty file
  const len = randIntRange(1, 64);
  if (kind === 1) {
    // Plain-ish text with newlines and tabs.
    let s = '';
    const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    return s;
  }
  // Arbitrary code points incl. unicode to exercise byte fidelity.
  let s = '';
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/**
 * Build a random nested relative POSIX path for a lib/ file (non-empty rest).
 * @returns {string}
 */
function randomRest() {
  const depth = randInt(3); // 0..2 intermediate directories
  const segs = [];
  for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
  segs.push(`${randomName(1, 8)}.dart`);
  return segs.join('/');
}

/** Silence console.log/console.error for the duration of `fn`. */
function withSilencedConsole(fn) {
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};
  try {
    return fn();
  } finally {
    console.log = origLog;
    console.error = origError;
  }
}

test('Property 16: saveToFlavor preserves the lib/ source and copies it byte-identically to the flavor folder, incl. overwrite', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-to-flavor-prop-');
    try {
      const flavor = pick(FLAVORS);
      const componentName = randomName(3, 10);
      const rest = randomRest();
      const sourceContent = randomContent();
      const sourceRel = `${componentName}/lib/${rest}`;
      const destRel = `${componentName}/.${flavor}/${rest}`;

      // In ~half the iterations pre-create a DIFFERENT-content file at the
      // destination to exercise the overwrite path (Req 12.4).
      const preExistDest = Math.random() < 0.5;
      const oldDestContent = `PREEXISTING::${sourceContent}::${randomName(4, 8)}`;

      const componentSpec = {
        name: componentName,
        lib: { [rest]: sourceContent },
      };
      if (preExistDest) {
        componentSpec.flavors = { [flavor]: { [rest]: oldDestContent } };
      }

      await buildRepo(repoRoot, { components: [componentSpec] });

      const sourceAbs = path.join(repoRoot, componentName, 'lib', rest);
      const destAbs = path.join(repoRoot, componentName, `.${flavor}`, rest);

      // Capture the source bytes before the copy.
      const srcBefore = await fsp.readFile(sourceAbs);

      const ctx = `iter=${i} flavor='${flavor}' component='${componentName}' rest='${rest}' overwrite=${preExistDest}`;

      // Run the copy with console silenced; it must succeed (exit code 0).
      const code = withSilencedConsole(() => saveToFlavor(repoRoot, flavor, sourceRel));
      assert.equal(code, 0, `saveToFlavor must return 0 (${ctx})`);

      // Source preserved: still exists and byte-identical to before (COPY, not move).
      assert.ok(fs.existsSync(sourceAbs), `source must still exist at ${sourceRel} (${ctx})`);
      const srcAfter = await fsp.readFile(sourceAbs);
      assert.ok(
        srcBefore.equals(srcAfter),
        `source at ${sourceRel} must be byte-identical to before (${ctx})`,
      );

      // Destination exists and is byte-identical to the source.
      assert.ok(fs.existsSync(destAbs), `destination must exist at ${destRel} (${ctx})`);
      const dstAfter = await fsp.readFile(destAbs);
      assert.ok(
        srcAfter.equals(dstAfter),
        `destination at ${destRel} must be byte-identical to the source (${ctx})`,
      );

      // Overwrite case: a pre-existing destination now holds the source content,
      // not its old content (Req 12.4).
      if (preExistDest) {
        assert.notEqual(
          dstAfter.toString('utf8'),
          oldDestContent,
          `pre-existing destination at ${destRel} must have been overwritten (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
