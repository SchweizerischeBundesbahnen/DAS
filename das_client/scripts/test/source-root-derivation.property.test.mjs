// source-root-derivation.property.test.mjs
//
// Property test for source-root derivation symmetry.
//
// Feature: flavor-code-switching, Property 23: Source-root derivation is
// symmetric and round-trips for lib/ and test/.
//
// For any <component> segment, any root in {lib, test}, any non-empty <rest>,
// and any valid flavor:
//   - splitSourceRoot('<component>/<root>/<rest>') returns
//     { ok: true, component, root, rest } with exactly those parts.
//   - deriveFlavorDest('<component>/<root>/<rest>', flavor) returns
//     { ok: true, dest: '<component>/.<flavor>/<root>/<rest>' }.
// Conversely, for a path whose first segment is a component but whose SECOND
// segment is neither lib nor test, OR which has no component segment, OR is
// otherwise malformed: both splitSourceRoot and deriveFlavorDest report failure
// ({ ok: false, reason: 'not_a_source_path' }) and derive no destination.
//
// Validates: Requirements 1.6, 12.2, 12.7
//
// Pure Node, zero third-party dependencies — no filesystem, no temp dirs.
// Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { splitSourceRoot, deriveFlavorDest, FLAVORS } from '../switch-flavor.mjs';

const ITERATIONS = 200; // >= 100 minimum per the plan.

/** The two recognized Flavor_Source_Roots. */
const SOURCE_ROOTS = ['lib', 'test'];

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

/**
 * Produce a random component-name segment: a non-empty identifier that contains
 * no slash (so it is a single path segment) and is not itself `lib`/`test`
 * (keeps negative cases unambiguous).
 */
function randomComponent() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.';
  for (;;) {
    const len = randIntRange(1, 12);
    let s = '';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    if (!SOURCE_ROOTS.includes(s)) return s;
  }
}

/** Produce a random single path segment (no slash), length 1..8. */
function randomSegment() {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(1, 8);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/**
 * Build a random non-empty nested POSIX remainder ending in a `.dart` file,
 * e.g. `src/sub/foo.dart` or `foo.dart`.
 */
function randomRest() {
  const depth = randInt(3); // 0..2 intermediate directories
  const segs = [];
  for (let d = 0; d < depth; d++) segs.push(randomSegment());
  segs.push(`${randomSegment()}.dart`);
  return segs.join('/');
}

/**
 * Build a random path that is NOT a flavor-managed source path. Covers:
 *   - a component with a SECOND segment that is neither lib nor test
 *     (e.g. <comp>/bin/x.dart, <comp>/src/x.dart),
 *   - a path with no component segment (lib/foo.dart, test/foo.dart),
 *   - otherwise-malformed shapes (empty rest, bare single segment, etc.).
 */
function randomNonSourcePath() {
  const kind = randInt(6);
  const comp = randomComponent();
  switch (kind) {
    case 0: {
      // <comp>/<bad-root>/<rest> — second segment is neither lib nor test.
      let badRoot;
      do {
        badRoot = randomSegment();
      } while (SOURCE_ROOTS.includes(badRoot));
      return `${comp}/${badRoot}/${randomRest()}`;
    }
    case 1:
      // No component segment: lib/foo.dart or test/foo.dart.
      return `${pick(SOURCE_ROOTS)}/${randomSegment()}.dart`;
    case 2:
      // Bare single segment (no root, no rest).
      return `${comp}`;
    case 3:
      // <comp>/<root> with EMPTY rest (trailing slash → no non-empty remainder).
      return `${comp}/${pick(SOURCE_ROOTS)}/`;
    case 4:
      // <comp>/<root> only (two segments, no rest).
      return `${comp}/${pick(SOURCE_ROOTS)}`;
    default:
      // A root-looking first segment with a nested rest but no component ahead.
      return `${pick(SOURCE_ROOTS)}/${randomSegment()}/${randomSegment()}.dart`;
  }
}

test(
  'Feature: flavor-code-switching, Property 23: Source-root derivation is symmetric and round-trips for lib/ and test/',
  () => {
    for (let i = 0; i < ITERATIONS; i++) {
      // ---- Positive case: a well-formed <component>/<root>/<rest> path. ----
      const component = randomComponent();
      const root = pick(SOURCE_ROOTS);
      const rest = randomRest();
      const flavor = pick(FLAVORS);
      const file = `${component}/${root}/${rest}`;

      const posCtx = `iter=${i} file='${file}' flavor='${flavor}'`;

      // splitSourceRoot returns exactly the three parts.
      const split = splitSourceRoot(file);
      assert.equal(split.ok, true, `splitSourceRoot must succeed (${posCtx})`);
      assert.equal(split.component, component, `component must round-trip (${posCtx})`);
      assert.equal(split.root, root, `root must round-trip (${posCtx})`);
      assert.equal(split.rest, rest, `rest must round-trip (${posCtx})`);

      // deriveFlavorDest inserts the .<flavor> folder, keeping the root segment.
      const derived = deriveFlavorDest(file, flavor);
      assert.equal(derived.ok, true, `deriveFlavorDest must succeed (${posCtx})`);
      assert.equal(
        derived.dest,
        `${component}/.${flavor}/${root}/${rest}`,
        `dest must be <component>/.<flavor>/<root>/<rest> (${posCtx})`,
      );

      // ---- Negative case: a non-source path is rejected by BOTH. ----
      const badFile = randomNonSourcePath();
      const negFlavor = pick(FLAVORS);
      const negCtx = `iter=${i} badFile='${badFile}' flavor='${negFlavor}'`;

      const badSplit = splitSourceRoot(badFile);
      assert.equal(badSplit.ok, false, `splitSourceRoot must reject non-source path (${negCtx})`);
      assert.equal(
        badSplit.reason,
        'not_a_source_path',
        `splitSourceRoot reason must be not_a_source_path (${negCtx})`,
      );

      const badDerived = deriveFlavorDest(badFile, negFlavor);
      assert.equal(badDerived.ok, false, `deriveFlavorDest must reject non-source path (${negCtx})`);
      assert.equal(
        badDerived.reason,
        'not_a_source_path',
        `deriveFlavorDest reason must be not_a_source_path (${negCtx})`,
      );
      // No destination derived on the failure path.
      assert.equal(
        badDerived.dest,
        undefined,
        `deriveFlavorDest must derive no dest on failure (${negCtx})`,
      );
    }
  },
);
