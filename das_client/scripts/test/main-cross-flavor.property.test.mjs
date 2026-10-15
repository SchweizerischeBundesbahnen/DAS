// main-cross-flavor.property.test.mjs
//
// Property test for end-to-end main() cross-flavor replacement.
//
// Feature: flavor-code-switching, Property 6: Cross-flavor switch replaces
// prior state: for a pair of distinct flavors A and B, after switching to A and
// then to B, the resulting manifest lists exactly B's copied targets, and every
// target path exclusive to A (present in A's set but not B's) no longer exists
// on disk.
//
// Validates: Requirements 2.4, 5.2
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { main, FLAVORS } from '../switch-flavor.mjs';
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
function randomName(minLen = 3, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content, including empty, text and unicode bytes. */
function randomContent() {
  const kind = randInt(3);
  if (kind === 0) return '';
  const len = randIntRange(1, 48);
  if (kind === 1) {
    let s = '';
    const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    return s;
  }
  let s = '';
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/**
 * Produce a set of distinct nested relative POSIX file paths.
 * @param {number} count
 * @param {Set<string>} used shared set to keep paths globally unique
 * @returns {string[]}
 */
function distinctRelPaths(count, used) {
  const out = [];
  let attempts = 0;
  while (out.length < count && attempts < count * 20) {
    attempts++;
    const depth = randInt(3); // 0..2 nested dirs
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 5));
    segs.push(`${randomName(1, 8)}.dart`);
    const rel = segs.join('/');
    if (used.has(rel)) continue;
    used.add(rel);
    out.push(rel);
  }
  return out;
}

/**
 * Swallow console output from main() so the test log stays readable while still
 * exercising the real orchestration (which logs a summary / skip notes).
 */
function withSilencedConsole(fn) {
  const log = console.log;
  const error = console.error;
  console.log = () => {};
  console.error = () => {};
  try {
    return fn();
  } finally {
    console.log = log;
    console.error = error;
  }
}

test('Property 6: switching A then B yields a manifest of exactly B targets; A-exclusive targets are gone', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-cross-prop-');
    try {
      // Pick two distinct flavors A, B.
      const flavorA = pick(FLAVORS);
      let flavorB = pick(FLAVORS);
      while (flavorB === flavorA) flavorB = pick(FLAVORS);

      // Build 1..3 components, each optionally owning folders for A and/or B.
      const componentCount = randIntRange(1, 3);
      const components = [];
      const usedRelPaths = new Set(); // keep rel paths unique across flavors/components

      // Expected repo-relative POSIX target sets per flavor.
      const expectedA = new Set();
      const expectedB = new Set();

      for (let c = 0; c < componentCount; c++) {
        const name = `comp_${i}_${c}_${randomName(2, 5)}`;
        const flavors = {};

        // Randomly decide ownership, but guarantee at least one file per flavor
        // somewhere in the repo (enforced after the loop as a fallback).
        const ownsA = Math.random() < 0.7;
        const ownsB = Math.random() < 0.7;

        if (ownsA) {
          const relsA = distinctRelPaths(randIntRange(1, 4), usedRelPaths);
          flavors[flavorA] = {};
          for (const rel of relsA) {
            flavors[flavorA][rel] = randomContent();
            expectedA.add(`${name}/lib/${rel}`);
          }
        }
        if (ownsB) {
          const relsB = distinctRelPaths(randIntRange(1, 4), usedRelPaths);
          flavors[flavorB] = {};
          for (const rel of relsB) {
            flavors[flavorB][rel] = randomContent();
            expectedB.add(`${name}/lib/${rel}`);
          }
        }

        components.push({ name, flavors });
      }

      // Guarantee both flavors have at least one file somewhere so that each
      // main() invocation finds a non-empty copy plan (empty plan → exit 1).
      // Also guarantee A has at least one path exclusive to B so the "exclusive
      // to A no longer exists" assertion is non-vacuous.
      const firstComp = components[0];

      const ensureFlavorFile = (flavor, expectedSet) => {
        if (expectedSet.size > 0) return;
        firstComp.flavors[flavor] = firstComp.flavors[flavor] ?? {};
        const [rel] = distinctRelPaths(1, usedRelPaths);
        firstComp.flavors[flavor][rel] = randomContent();
        expectedSet.add(`${firstComp.name}/lib/${rel}`);
      };
      ensureFlavorFile(flavorA, expectedA);
      ensureFlavorFile(flavorB, expectedB);

      // Guarantee at least one A-exclusive target (in A but not B). Because rel
      // paths are globally unique, A and B targets never overlap by path, so
      // every A target is already exclusive — but assert the invariant here so
      // a future generator change can't silently make the property vacuous.
      // (Add one extra A-only file to be safe/explicit.)
      {
        firstComp.flavors[flavorA] = firstComp.flavors[flavorA] ?? {};
        const [rel] = distinctRelPaths(1, usedRelPaths);
        firstComp.flavors[flavorA][rel] = randomContent();
        expectedA.add(`${firstComp.name}/lib/${rel}`);
      }

      await buildRepo(repoRoot, { components });

      const ctx = `iter=${i} A='${flavorA}' B='${flavorB}' |A|=${expectedA.size} |B|=${expectedB.size}`;

      // Switch to A, then to B. Both must succeed (exit 0).
      const codeA = withSilencedConsole(() =>
        main(['node', 'switch-flavor.mjs', flavorA], { repoRoot }),
      );
      assert.equal(codeA, 0, `switch to A must return 0 (${ctx})`);

      const codeB = withSilencedConsole(() =>
        main(['node', 'switch-flavor.mjs', flavorB], { repoRoot }),
      );
      assert.equal(codeB, 0, `switch to B must return 0 (${ctx})`);

      // Read the resulting manifest directly.
      const manifestPath = path.join(repoRoot, '.flavor-manifest.json');
      const manifest = JSON.parse(await fsp.readFile(manifestPath, 'utf8'));

      // manifest is schema v2: `files` is an array of `{ path, overwrote }`
      // entries. Compare over the path set.
      assert.equal(manifest.version, 2, `manifest.version must be 2 (${ctx})`);
      const manifestPaths = manifest.files.map((e) => e.path);

      // manifest.flavor === B.
      assert.equal(manifest.flavor, flavorB, `manifest.flavor must equal B (${ctx})`);

      // manifest.files === exactly B's expected targets (set equality over paths).
      assert.deepEqual(
        [...manifestPaths].sort(),
        [...expectedB].sort(),
        `manifest.files must equal exactly B's targets (${ctx})`,
      );

      // Every target exclusive to A (in A's set but not B's) no longer exists.
      const exclusiveToA = [...expectedA].filter((p) => !expectedB.has(p));
      assert.ok(
        exclusiveToA.length > 0,
        `generator must produce at least one A-exclusive target (${ctx})`,
      );
      for (const rel of exclusiveToA) {
        const abs = path.join(repoRoot, rel);
        assert.ok(
          !fs.existsSync(abs),
          `A-exclusive target must be deleted after switching to B: ${rel} (${ctx})`,
        );
      }

      // Every B target exists on disk.
      for (const rel of expectedB) {
        const abs = path.join(repoRoot, rel);
        assert.ok(
          fs.existsSync(abs),
          `B target must exist on disk after switching to B: ${rel} (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
