// main-firstrun-corrupt.property.test.mjs
//
// End-to-end property test for main() first-run and corrupt-manifest safety.
//
// Feature: flavor-code-switching, Property 7: First-run and corrupt-manifest
// safety: for any fixture where the manifest is absent OR cannot be parsed as
// valid manifest data, the switch copies the selected flavor's files and writes
// a new manifest while deleting ZERO files. Pre-existing unrelated lib/ files
// MUST survive byte-identical because deletion is skipped without a valid prior
// manifest.
//
// Validates: Requirements 4.1, 4.2
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { main, FLAVORS, MANIFEST_VERSION } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo, readFileOrUndefined } from './helpers.mjs';

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

/** Random file content, incl. unicode, to exercise byte fidelity. */
function randomContent(tag = '') {
  const len = randIntRange(0, 48);
  let s = tag;
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/**
 * Build a random nested tree of flavor-source files: POSIX relpath -> content.
 * Guarantees at least one file so the copy plan is non-empty (main exits 1 on
 * an empty plan, which is not the scenario under test here).
 * @returns {Record<string, string>}
 */
function randomFlavorTree() {
  const fileCount = randIntRange(1, 6);
  const tree = {};
  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10) {
    attempts++;
    const depth = randInt(3); // 0..2 nested dirs
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
    segs.push(`${randomName(1, 8)}.dart`);
    const rel = segs.join('/');
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent('FLAVOR::');
  }
  return tree;
}

/**
 * Pre-existing unrelated lib/ files that must NOT be touched. Deliberately use
 * a distinct `unrelated_` prefix so they never collide with a flavor target
 * (flavor files use `.dart` leaf names generated above and would only overwrite
 * their own targets, never these).
 * @returns {Record<string, string>}
 */
function randomUnrelatedLib() {
  const fileCount = randIntRange(1, 5);
  const tree = {};
  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10) {
    attempts++;
    const rel = `unrelated_${randomName(2, 8)}/${randomName(1, 6)}.keep`;
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent('UNRELATED::');
  }
  return tree;
}

/**
 * Produce a manifest payload that is NOT valid manifest data. Randomized across
 * sub-cases: non-JSON garbage, valid JSON of the wrong top-level type, and
 * JSON objects that fail shape validation (bad version / bad flavor / files not
 * an array of strings). Each one must drive readManifest to CORRUPT.
 * @returns {string}
 */
function randomCorruptManifestRaw() {
  const kind = randInt(6);
  switch (kind) {
    case 0:
      // Non-JSON garbage.
      return randomName(1, 40) + '{not: json,,';
    case 1:
      // Valid JSON but not an object (array).
      return JSON.stringify([1, 2, 3]);
    case 2:
      // Valid JSON scalar.
      return JSON.stringify(randomName(1, 10));
    case 3:
      // Object with wrong version.
      return JSON.stringify({ version: MANIFEST_VERSION + 1, flavor: pick(FLAVORS), files: [] });
    case 4:
      // Object with an invalid flavor.
      return JSON.stringify({ version: MANIFEST_VERSION, flavor: randomName(1, 6), files: [] });
    default:
      // Object with files that is not an array of strings.
      return JSON.stringify({ version: MANIFEST_VERSION, flavor: pick(FLAVORS), files: [1, 2, 3] });
  }
}

test('Property 7: first-run/corrupt manifest copies flavor files, writes new manifest, deletes zero files', async () => {
  // Silence main()'s console output during the property run.
  const origLog = console.log;
  const origError = console.error;
  console.log = () => {};
  console.error = () => {};

  try {
    for (let i = 0; i < ITERATIONS; i++) {
      const repoRoot = await makeTempDir('flavor-firstrun-prop-');
      try {
        const flavor = pick(FLAVORS);
        // At least one component owns the chosen flavor folder.
        const componentCount = randIntRange(1, 3);
        const components = [];
        // Track expected flavor targets (repo-relative POSIX) and content.
        const expectedTargets = {}; // repoRelPosix -> content
        // Track pre-existing unrelated lib files (absolute) -> original bytes.
        const unrelatedByAbs = new Map();

        for (let c = 0; c < componentCount; c++) {
          const name = `comp_${randomName(2, 8)}_${c}`;
          const flavorTree = randomFlavorTree();
          const unrelatedLib = randomUnrelatedLib();

          for (const [rel, content] of Object.entries(flavorTree)) {
            expectedTargets[`${name}/lib/${rel}`] = content;
          }
          for (const rel of Object.keys(unrelatedLib)) {
            unrelatedByAbs.set(path.join(repoRoot, name, 'lib', rel), unrelatedLib[rel]);
          }

          components.push({
            name,
            lib: unrelatedLib,
            flavors: { [flavor]: flavorTree },
          });
        }

        // Sub-case (a) no manifest at all; (b) a corrupt manifest.
        const firstRun = Math.random() < 0.5;
        const repoSpec = { components };
        if (!firstRun) {
          repoSpec.manifestRaw = randomCorruptManifestRaw();
        }
        await buildRepo(repoRoot, repoSpec);

        // Capture pre-existing unrelated lib bytes BEFORE the switch.
        const beforeBytes = new Map();
        for (const abs of unrelatedByAbs.keys()) {
          beforeBytes.set(abs, await fsp.readFile(abs));
        }

        const ctx = `iter=${i} flavor='${flavor}' firstRun=${firstRun} comps=${componentCount}`;

        // Run the end-to-end switch.
        const code = main([process.argv0, 'switch-flavor.mjs', flavor], { repoRoot });
        assert.equal(code, 0, `main must exit 0 (${ctx})`);

        // A new VALID manifest now exists: readable JSON with version/flavor/files.
        const manifestText = await readFileOrUndefined(path.join(repoRoot, '.flavor-manifest.json'));
        assert.ok(manifestText !== undefined, `a new manifest must exist (${ctx})`);
        let manifest;
        assert.doesNotThrow(() => {
          manifest = JSON.parse(manifestText);
        }, `new manifest must be valid JSON (${ctx})`);
        assert.equal(manifest.version, MANIFEST_VERSION, `manifest.version must be ${MANIFEST_VERSION} (${ctx})`);
        assert.equal(manifest.flavor, flavor, `manifest.flavor must record the switch (${ctx})`);
        assert.ok(Array.isArray(manifest.files), `manifest.files must be an array (${ctx})`);
        // Schema v2: every entry is a `{ path: string, overwrote: boolean }` object.
        assert.ok(
          manifest.files.every(
            (f) =>
              typeof f === 'object' &&
              f !== null &&
              typeof f.path === 'string' &&
              typeof f.overwrote === 'boolean',
          ),
          `manifest.files must be { path, overwrote } entry objects (${ctx})`,
        );

        // The manifest lists exactly the flavor targets that were copied (paths).
        const manifestPaths = manifest.files.map((e) => e.path);
        assert.deepEqual(
          [...manifestPaths].sort(),
          Object.keys(expectedTargets).sort(),
          `manifest.files must equal the copied flavor targets (${ctx})`,
        );

        // The flavor files were copied byte-identical to their lib/ targets.
        for (const [relTarget, content] of Object.entries(expectedTargets)) {
          const abs = path.join(repoRoot, relTarget);
          assert.ok(fs.existsSync(abs), `flavor target must exist: ${relTarget} (${ctx})`);
          const dst = await fsp.readFile(abs);
          assert.equal(dst.toString('utf8'), content, `flavor target content must match: ${relTarget} (${ctx})`);
        }

        // ZERO deletions: every pre-existing unrelated lib file still exists
        // and is byte-identical to before the switch.
        for (const [abs, originalBytes] of beforeBytes.entries()) {
          assert.ok(fs.existsSync(abs), `pre-existing unrelated lib file must survive: ${abs} (${ctx})`);
          const after = await fsp.readFile(abs);
          assert.ok(
            after.equals(originalBytes),
            `pre-existing unrelated lib file must be byte-identical (zero deletions): ${abs} (${ctx})`,
          );
        }
      } finally {
        await removeTempDir(repoRoot);
      }
    }
  } finally {
    console.log = origLog;
    console.error = origError;
  }
});
