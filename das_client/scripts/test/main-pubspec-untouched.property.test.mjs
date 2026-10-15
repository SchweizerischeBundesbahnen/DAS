// main-pubspec-untouched.property.test.mjs
//
// End-to-end property test exercising main() for the guarantee that a switch
// invoked WITHOUT a remove-dependency flag never touches app/pubspec.yaml.
//
// Feature: flavor-code-switching, Property 12: Pubspec untouched without the
// remove-dep flag: for any switch invoked without a remove-dependency flag,
// app/pubspec.yaml SHALL be byte-identical before and after the run.
//
// Validates: Requirements 7.4
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

import { main, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo, SOURCE_ROOTS } from './helpers.mjs';

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

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 3, maxLen = 10) {
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
    let s = '';
    const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    return s;
  }
  let s = '';
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/** Build unique component names, avoiding `app` (the helper always creates it). */
function uniqueNames(count) {
  const taken = new Set(['app']);
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
 * Build a random nested tree of files keyed by flavor-folder-relative POSIX
 * path. Every key is prefixed with a recognized Flavor_Source_Root (`lib/` or
 * `test/`), because a switch only copies `.<flavor>/lib/` and `.<flavor>/test/`
 * (mapping `.<flavor>/<root>/<rest>` → `<component>/<root>/<rest>`). The dir
 * pool mixes both roots so a fixture spreads files across them. Guarantees at
 * least one file so the owning component contributes a copy.
 * @returns {Record<string,string>}
 */
function randomFileTree() {
  const fileCount = randIntRange(1, 6);
  const tree = {};
  // Each prefix starts at a source root so files always land under lib/ or test/.
  const dirPool = SOURCE_ROOTS.map((root) => root);
  const extraDirs = randInt(3);
  for (let i = 0; i < extraDirs; i++) {
    const depth = randIntRange(1, 3);
    const segs = [pick(SOURCE_ROOTS)];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 6));
    dirPool.push(segs.join('/'));
  }

  let attempts = 0;
  while (Object.keys(tree).length < fileCount && attempts < fileCount * 10) {
    attempts++;
    const dir = pick(dirPool);
    const fileName = `${randomName(1, 8)}.dart`;
    const rel = `${dir}/${fileName}`;
    if (Object.prototype.hasOwnProperty.call(tree, rel)) continue;
    tree[rel] = randomContent();
  }
  return tree;
}

/**
 * Build a random repo spec where at least one component owns a folder for the
 * chosen flavor (so the copy plan is non-empty and main returns 0). Some
 * components get other-flavor folders or no flavor folder as noise.
 * @param {string} flavor
 */
function buildSpec(flavor) {
  const otherFlavors = FLAVORS.filter((f) => f !== flavor);
  const names = uniqueNames(randIntRange(1, 5));

  const components = [];
  let owners = 0;

  for (let i = 0; i < names.length; i++) {
    const name = names[i];
    const roll = Math.random();
    // Force the last component to own the flavor if none has so far, so the
    // copy plan is guaranteed non-empty and main succeeds (code 0).
    const mustOwn = owners === 0 && i === names.length - 1;

    if (mustOwn || roll < 0.6) {
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [flavor]: randomFileTree() },
      });
      owners++;
    } else if (roll < 0.8) {
      // lib/ only, no flavor folder.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
      });
    } else {
      // Only a different flavor's folder.
      components.push({
        name,
        lib: { 'placeholder.dart': '// placeholder\n' },
        flavors: { [pick(otherFlavors)]: randomFileTree() },
      });
    }
  }

  return { components };
}

/** Silence main()'s console output for the duration of `fn`. */
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

test('Property 12: a switch without --remove-dep leaves app/pubspec.yaml byte-identical', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-pubspec-untouched-prop-');
    try {
      const flavor = pick(FLAVORS);
      const spec = buildSpec(flavor);
      await buildRepo(repoRoot, spec);

      const pubspecPath = path.join(repoRoot, 'app', 'pubspec.yaml');
      // Record app/pubspec.yaml bytes BEFORE the run (raw buffer, not text).
      const before = fs.readFileSync(pubspecPath);

      // Invoke with NO --remove-dep flag.
      const argv = ['node', 'switch-flavor.mjs', flavor];
      const ctx = `iter=${i} flavor='${flavor}'`;

      // A spawn stub that would make noise if ever called — without
      // --remove-dep, workspace resolution must never be triggered.
      let spawnCalled = false;
      const spawn = () => {
        spawnCalled = true;
        return { status: 0 };
      };

      const code = withSilencedConsole(() => main(argv, { repoRoot, spawn }));

      // The switch must succeed (non-empty copy plan guaranteed by buildSpec).
      assert.equal(code, 0, `switch must exit 0 (${ctx})`);
      assert.equal(spawnCalled, false, `resolution must not be spawned without --remove-dep (${ctx})`);

      // app/pubspec.yaml must be byte-identical after the run.
      const after = fs.readFileSync(pubspecPath);
      assert.ok(
        before.equals(after),
        `app/pubspec.yaml must be byte-identical before and after the run (${ctx})`,
      );
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
