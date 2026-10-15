// copy-files.property.test.mjs
//
// Property test for planCopy + copyFiles copy fidelity and structure
// preservation.
//
// Feature: flavor-code-switching, Property 2: Copy fidelity and structure
// preservation: for a flavor folder containing an arbitrary nested tree of
// files, after a copy every source file at <component>/<flavor>/<relpath>
// exists at <component>/lib/<relpath> with byte-identical content, whether or
// not a file already existed at the target. copyFiles returns one
// `{ path, overwrote }` entry per written target — exactly the mapped
// repo-relative POSIX target paths, with `overwrote` reflecting pre-existence.
//
// Validates: Requirements 1.3, 1.4
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { planCopy, copyFiles, FLAVORS } from '../switch-flavor.mjs';
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
    // Plain-ish text with newlines.
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
 * Build a random nested tree of files as a map of POSIX relative path → content.
 * Guarantees at least one file. Paths are nested under random subdirectories.
 * @returns {Record<string, string>}
 */
function randomTree() {
  const fileCount = randIntRange(1, 8);
  const tree = {};
  // A small pool of directory prefixes so files share intermediate dirs,
  // exercising the "create missing intermediate dirs once" behaviour.
  const dirPool = [''];
  const extraDirs = randInt(4);
  for (let i = 0; i < extraDirs; i++) {
    const depth = randIntRange(1, 3);
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
    dirPool.push(segs.join('/'));
  }

  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10) {
    attempts++;
    const dir = pick(dirPool);
    const fileName = `${randomName(1, 8)}.dart`;
    const rel = dir === '' ? fileName : `${dir}/${fileName}`;
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue; // avoid collisions
    tree[rel] = randomContent();
  }
  return tree;
}

test('Property 2: planCopy + copyFiles preserves nested structure with byte-identical content, incl. overwrite', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-copy-prop-');
    try {
      const flavor = pick(FLAVORS);
      const componentName = randomName(3, 10);
      const tree = randomTree();

      // Decide, per flavor source file, whether to pre-create a conflicting
      // file at the lib/ target with DIFFERENT content to prove overwrite.
      const preexistingLib = {};
      for (const rel of Object.keys(tree)) {
        if (Math.random() < 0.5) {
          // Content guaranteed different from the flavor source.
          preexistingLib[rel] = `PREEXISTING::${tree[rel]}::${randomName(4, 8)}`;
        }
      }

      await buildRepo(repoRoot, {
        components: [
          {
            name: componentName,
            lib: preexistingLib,
            flavors: { [flavor]: tree },
          },
        ],
      });

      const componentDir = path.join(repoRoot, componentName);

      // Build the plan and run the copy.
      const plan = planCopy(componentDir, flavor, repoRoot);
      const written = copyFiles(plan, repoRoot);

      const ctx = `iter=${i} flavor='${flavor}' component='${componentName}' files=${Object.keys(tree).length}`;

      // The plan must cover exactly the flavor source files (one entry each).
      assert.equal(
        plan.length,
        Object.keys(tree).length,
        `plan must have one entry per flavor source file (${ctx})`,
      );

      // Expected repo-relative POSIX targets: <component>/lib/<relpath>.
      const expectedTargets = Object.keys(tree)
        .map((rel) => `${componentName}/lib/${rel}`)
        .sort();

      // copyFiles returns exactly the mapped target paths (set equality).
      // Under schema v2 each written entry is a `{ path, overwrote }` object, so
      // compare over the `.path` values.
      const writtenPaths = written.map((e) => e.path);
      assert.deepEqual(
        [...writtenPaths].sort(),
        expectedTargets,
        `copyFiles must return exactly the mapped target paths (${ctx})`,
      );
      // And no duplicate targets.
      assert.equal(
        new Set(writtenPaths).size,
        writtenPaths.length,
        `copyFiles targets must be unique (${ctx})`,
      );

      // Each entry's `overwrote` flag must reflect whether a Base_File already
      // existed at that target before the copy (Req 10.2, 10.3, 10.4).
      for (const entry of written) {
        const rel = entry.path.slice(`${componentName}/lib/`.length);
        const preExisted = Object.prototype.hasOwnProperty.call(preexistingLib, rel);
        assert.equal(
          entry.overwrote,
          preExisted,
          `overwrote flag for ${entry.path} must match pre-existence (${ctx})`,
        );
      }

      // Every flavor source file now exists at its lib/ target with
      // byte-identical content — overwrite case included.
      for (const rel of Object.keys(tree)) {
        const sourceAbs = path.join(componentDir, flavor, rel);
        const targetAbs = path.join(componentDir, 'lib', rel);

        assert.ok(fs.existsSync(targetAbs), `target must exist at lib/${rel} (${ctx})`);

        const srcBuf = await fsp.readFile(sourceAbs);
        const dstBuf = await fsp.readFile(targetAbs);
        assert.ok(
          srcBuf.equals(dstBuf),
          `content at lib/${rel} must be byte-identical to flavor source (${ctx})`,
        );

        // Where we pre-seeded a conflicting file, prove it was overwritten
        // (the destination no longer holds the preexisting content).
        if (Object.prototype.hasOwnProperty.call(preexistingLib, rel)) {
          assert.notEqual(
            dstBuf.toString('utf8'),
            preexistingLib[rel],
            `preexisting target at lib/${rel} must have been overwritten (${ctx})`,
          );
        }
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
