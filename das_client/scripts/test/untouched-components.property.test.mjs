// untouched-components.property.test.mjs
//
// Property test for non-matching components being left untouched by a switch.
//
// Feature: flavor-code-switching, Property 3: Non-matching components are
// untouched: for any component that has NO folder matching the selected flavor,
// its lib/ folder is byte-identical before and after a switch/copy (same file
// set, same contents). As a corollary, a matching component whose flavor folder
// writes into a DIFFERENT subpath must not disturb unrelated pre-existing lib
// files.
//
// Validates: Requirements 1.5
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { discoverComponents, planCopy, copyFiles } from '../switch-flavor.mjs';
import { withTempDir, buildRepo } from './helpers.mjs';

const ITERATIONS = 120; // >= 100 minimum per the plan.
const FLAVORS = ['dev', 'inte', 'prod'];

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
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Build `count` unique names, avoiding any already in `taken`. */
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

/** Random file content with varied bytes (incl. newlines) to exercise fidelity. */
function randomContent() {
  const lines = randIntRange(0, 5);
  const parts = [];
  for (let i = 0; i < lines; i++) parts.push(randomName(0, 24));
  return parts.join('\n');
}

/**
 * Build a random lib/ tree: a map of relative POSIX path -> content.
 * Uses a mix of root-level and nested files (incl. a `src/` subdir) so the
 * snapshot exercises nested structure.
 * @param {Set<string>} taken file-base-name pool to keep paths unique
 */
function randomLibTree() {
  const tree = {};
  const fileCount = randIntRange(1, 5);
  const used = new Set();
  for (let i = 0; i < fileCount; i++) {
    let rel;
    do {
      const depth = randInt(3); // 0, 1, or 2 nested dirs
      const segs = [];
      for (let d = 0; d < depth; d++) segs.push(randomName(2, 6));
      segs.push(`${randomName(2, 8)}.dart`);
      rel = segs.join('/');
    } while (used.has(rel));
    used.add(rel);
    tree[rel] = randomContent();
  }
  return tree;
}

/**
 * Snapshot the full lib/ tree of a component directory as a sorted map of
 * repo-relative-ish path (relative to the lib dir) -> sha256 hash of bytes.
 * Returns `{ files, hashes }` where `files` is the sorted relative path list
 * and `hashes` maps each path to its content hash.
 * @param {string} libDir absolute path to the component's lib/ directory
 * @returns {Promise<{files: string[], hashes: Record<string, string>}>}
 */
async function snapshotLib(libDir) {
  const hashes = {};

  async function walk(current) {
    let dirents;
    try {
      dirents = await fsp.readdir(current, { withFileTypes: true });
    } catch (err) {
      if (err && err.code === 'ENOENT') return; // no lib dir at all
      throw err;
    }
    for (const dirent of dirents) {
      const abs = path.join(current, dirent.name);
      if (dirent.isDirectory()) {
        await walk(abs);
      } else if (dirent.isFile()) {
        const rel = path.relative(libDir, abs).split(path.sep).join('/');
        const bytes = await fsp.readFile(abs);
        hashes[rel] = crypto.createHash('sha256').update(bytes).digest('hex');
      }
    }
  }

  await walk(libDir);
  const files = Object.keys(hashes).sort();
  return { files, hashes };
}

test('Property 3: non-matching components keep a byte-identical lib/ across a switch', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const flavor = pick(FLAVORS);
    const otherFlavors = FLAVORS.filter((f) => f !== flavor);

    await withTempDir(async (dir) => {
      const taken = new Set(['app']);
      const componentCount = randIntRange(2, 5);
      const names = uniqueNames(componentCount, taken);

      /** @type {Array<{name: string, matching: boolean}>} */
      const descriptors = [];
      const componentSpecs = [];

      // Ensure at least one matching and at least one non-matching component so
      // every iteration meaningfully exercises both sides.
      const forcedMatchIdx = randInt(names.length);
      let forcedNonMatchIdx = randInt(names.length);
      if (forcedNonMatchIdx === forcedMatchIdx) {
        forcedNonMatchIdx = (forcedNonMatchIdx + 1) % names.length;
      }

      for (let n = 0; n < names.length; n++) {
        const name = names[n];
        let matching;
        if (n === forcedMatchIdx) matching = true;
        else if (n === forcedNonMatchIdx) matching = false;
        else matching = Math.random() < 0.5;

        const lib = randomLibTree();
        const flavors = {};

        if (matching) {
          // Matching component: its flavor folder writes into a DIFFERENT
          // subpath (under `generated/`) than any pre-existing lib file, so we
          // can assert the copy does not disturb unrelated lib files.
          const genFiles = {};
          const genCount = randIntRange(1, 3);
          const usedGen = new Set();
          for (let g = 0; g < genCount; g++) {
            let rel;
            do {
              rel = `generated/${randomName(3, 8)}.dart`;
            } while (usedGen.has(rel));
            usedGen.add(rel);
            genFiles[rel] = randomContent();
          }
          flavors[flavor] = genFiles;
        } else {
          // Non-matching component: give it folders for OTHER flavors only
          // (sometimes), but never the selected one.
          if (Math.random() < 0.6) {
            const other = pick(otherFlavors);
            flavors[other] = { [`${randomName()}.dart`]: randomContent() };
          }
        }

        descriptors.push({ name, matching });
        componentSpecs.push({ name, lib, flavors });
      }

      await buildRepo(dir, { components: componentSpecs });

      const nonMatchingNames = descriptors.filter((d) => !d.matching).map((d) => d.name);
      const matchingNames = descriptors.filter((d) => d.matching).map((d) => d.name);
      const ctx = `flavor='${flavor}', matching=[${matchingNames}], nonMatching=[${nonMatchingNames}]`;

      // Snapshot every component's lib/ before the switch.
      const before = {};
      for (const d of descriptors) {
        before[d.name] = await snapshotLib(path.join(dir, d.name, 'lib'));
      }

      // Build the full copy plan across all components for the selected flavor,
      // then execute the copy exactly as main() would.
      const components = discoverComponents(dir);
      const plan = components.flatMap((c) => planCopy(c.dir, flavor, dir));
      copyFiles(plan, dir);

      // Re-snapshot and assert.
      for (const d of descriptors) {
        const after = await snapshotLib(path.join(dir, d.name, 'lib'));

        if (!d.matching) {
          // Non-matching component: lib/ must be byte-identical (same file set,
          // same content hashes).
          assert.deepEqual(
            after.files,
            before[d.name].files,
            `non-matching '${d.name}' lib file set changed (${ctx})`,
          );
          assert.deepEqual(
            after.hashes,
            before[d.name].hashes,
            `non-matching '${d.name}' lib contents changed (${ctx})`,
          );
        } else {
          // Matching component: every pre-existing lib file (written under
          // random non-`generated/` paths) must survive untouched. The copy
          // only adds files under `generated/`.
          for (const rel of before[d.name].files) {
            assert.equal(
              after.hashes[rel],
              before[d.name].hashes[rel],
              `matching '${d.name}' disturbed pre-existing lib file '${rel}' (${ctx})`,
            );
          }
          // And the plan's generated/ targets must now be present.
          const addedUnderGenerated = after.files.filter(
            (f) => !before[d.name].files.includes(f),
          );
          assert.ok(
            addedUnderGenerated.every((f) => f.startsWith('generated/')),
            `matching '${d.name}' added files outside generated/: [${addedUnderGenerated}] (${ctx})`,
          );
        }
      }
    });
  }
});
