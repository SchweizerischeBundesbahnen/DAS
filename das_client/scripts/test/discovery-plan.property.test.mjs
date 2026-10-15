// discovery-plan.property.test.mjs
//
// Property test for discoverComponents + planCopy selection.
//
// Feature: flavor-code-switching, Property 1: Discovery selects exactly the
// matching components: for any fixture of workspace components where an
// arbitrary subset owns a folder named after the selected flavor, the copy plan
// includes files from exactly those components that own the matching flavor
// folder, and from no others. Excluded tooling/hidden directories never appear.
//
// Validates: Requirements 1.2, 1.5
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';

import { FLAVORS, discoverComponents, planCopy } from '../switch-flavor.mjs';
import { makeTempDir, buildRepo, removeTempDir } from './helpers.mjs';

const ITERATIONS = 120; // >= 100 minimum per the plan.

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

/** Coin flip with the given probability of true. */
function chance(p) {
  return Math.random() < p;
}

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 3, maxLen = 10) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/**
 * Build a set of unique component names so no two collide.
 * @param {number} count
 * @param {Set<string>} taken names already in use
 */
function uniqueNames(count, taken) {
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
 * Build a random nested tree of small files, keyed by relative POSIX path.
 * At least one file so the owning component always contributes a copy entry.
 * @returns {Record<string,string>}
 */
function randomFileTree() {
  const fileCount = randIntRange(1, 4);
  const tree = {};
  for (let i = 0; i < fileCount; i++) {
    const depth = randIntRange(0, 2);
    const segments = [];
    for (let d = 0; d < depth; d++) segments.push(randomName(2, 5));
    segments.push(`${randomName(2, 6)}.dart`);
    const rel = segments.join('/');
    if (tree[rel] !== undefined) continue; // skip accidental collisions
    tree[rel] = `// ${rel}\nvar v = ${randInt(1000)};\n`;
  }
  return tree;
}

// Directory names that discovery must always exclude (hidden + known tooling).
const EXCLUDED_DIR_NAMES = ['.kiro', '.fvm', '.dart_tool', 'build', 'scripts', '.git', '.idea'];

/**
 * Build one random miniature-repo spec.
 *
 * Produces a mix of:
 *   - components that OWN the selected flavor folder (expected to contribute),
 *   - components with lib/ but NO flavor folder (must contribute nothing),
 *   - components that own a DIFFERENT flavor folder only (must contribute
 *     nothing for the selected flavor),
 *   - a component missing lib/ (not a valid component),
 *   - a component missing pubspec.yaml (not a valid component).
 *
 * @param {string} flavor the selected flavor
 * @returns {{ spec: object, expectedOwners: Set<string> }}
 */
function buildSpec(flavor) {
  const taken = new Set(['app']); // helper always creates `app`.
  const otherFlavors = FLAVORS.filter((f) => f !== flavor);

  const componentCount = randIntRange(3, 8);
  const names = uniqueNames(componentCount, taken);

  const components = [];
  const expectedOwners = new Set();

  for (const name of names) {
    const roll = Math.random();

    if (roll < 0.4) {
      // Owns the selected flavor folder → expected to contribute.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: randomFileTree() },
      });
      expectedOwners.add(name);
    } else if (roll < 0.6) {
      // lib/ but no flavor folder → contributes nothing.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
      });
    } else if (roll < 0.78) {
      // Owns only a DIFFERENT flavor folder → contributes nothing for `flavor`.
      const other = pick(otherFlavors);
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [other]: randomFileTree() },
      });
    } else if (roll < 0.86) {
      // Owns BOTH the selected flavor AND another flavor → expected to
      // contribute (only the selected flavor's files).
      const other = pick(otherFlavors);
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: randomFileTree(), [other]: randomFileTree() },
      });
      expectedOwners.add(name);
    } else if (roll < 0.93) {
      // Missing lib/ → not a valid component (even if it has a flavor folder).
      components.push({
        name,
        noLib: true,
        flavors: { [flavor]: randomFileTree() },
      });
    } else {
      // Missing pubspec.yaml → not a valid component.
      components.push({
        name,
        noPubspec: true,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: randomFileTree() },
      });
    }
  }

  return { spec: { components }, expectedOwners };
}

/**
 * Scatter random tooling/hidden directories into the repo root. Some of them
 * are shaped like valid components (pubspec.yaml + lib/ + a flavor folder) to
 * ensure discovery excludes them by NAME, not merely by shape.
 * @param {string} repoRoot
 * @param {string} flavor
 */
async function addExcludedDirs(repoRoot, flavor) {
  const count = randIntRange(1, EXCLUDED_DIR_NAMES.length);
  const shuffled = [...EXCLUDED_DIR_NAMES].sort(() => Math.random() - 0.5).slice(0, count);
  for (const name of shuffled) {
    const dir = path.join(repoRoot, name);
    await fs.mkdir(dir, { recursive: true });
    // Make it LOOK like a component to prove name-based exclusion.
    if (chance(0.6)) {
      await fs.writeFile(path.join(dir, 'pubspec.yaml'), 'name: tooling\n');
      await fs.mkdir(path.join(dir, 'lib'), { recursive: true });
      await fs.writeFile(path.join(dir, 'lib', 'x.dart'), '// x\n');
      await fs.mkdir(path.join(dir, `.${flavor}`), { recursive: true });
      await fs.writeFile(path.join(dir, `.${flavor}`, 'y.dart'), '// y\n');
    } else {
      await fs.writeFile(path.join(dir, 'junk.txt'), 'junk\n');
    }
  }
}

test('Property 1: discovery/plan selects exactly the components owning the matching flavor folder', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const flavor = pick(FLAVORS);
    const { spec, expectedOwners } = buildSpec(flavor);

    const dir = await makeTempDir();
    try {
      await buildRepo(dir, spec);
      await addExcludedDirs(dir, flavor);

      const ctx = `iteration=${i} flavor='${flavor}' expectedOwners=[${[...expectedOwners].sort().join(', ')}]`;

      // Discover components, then build the copy plan across all of them.
      const components = discoverComponents(dir);

      // No excluded/tooling/hidden dir may ever be discovered as a component.
      for (const comp of components) {
        assert.ok(
          !EXCLUDED_DIR_NAMES.includes(comp.name),
          `excluded dir '${comp.name}' must not be discovered (${ctx})`,
        );
        assert.ok(!comp.name.startsWith('.'), `hidden dir '${comp.name}' must not be discovered (${ctx})`);
      }

      // The set of components contributing copy entries.
      const contributing = new Set();
      const allTargets = [];
      for (const comp of components) {
        const entries = planCopy(comp.dir, flavor, dir);
        if (entries.length > 0) {
          contributing.add(comp.name);
          for (const e of entries) allTargets.push(e);
        }
      }

      // The contributing set must equal EXACTLY the set of flavor-folder owners.
      const contributingSorted = [...contributing].sort();
      const expectedSorted = [...expectedOwners].sort();
      assert.deepEqual(
        contributingSorted,
        expectedSorted,
        `contributing components must equal exactly the matching-flavor owners (${ctx}); got [${contributingSorted.join(', ')}]`,
      );

      // Every copy target must land under <component>/lib/ for an expected
      // owner, and never reference an excluded directory.
      for (const entry of allTargets) {
        const [first] = entry.target.split('/');
        assert.ok(
          expectedOwners.has(first),
          `copy target '${entry.target}' must belong to an expected owner (${ctx})`,
        );
        assert.ok(
          entry.target.startsWith(`${first}/lib/`),
          `copy target '${entry.target}' must land under '${first}/lib/' (${ctx})`,
        );
        for (const excluded of EXCLUDED_DIR_NAMES) {
          assert.ok(
            !entry.target.split('/').includes(excluded),
            `copy target '${entry.target}' must not reference excluded dir '${excluded}' (${ctx})`,
          );
        }
        // Source must point at the component's selected-flavor folder.
        assert.ok(
          entry.source.includes(`${path.sep}.${flavor}${path.sep}`),
          `copy source '${entry.source}' must come from the '${flavor}' folder (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(dir);
    }
  }
});
