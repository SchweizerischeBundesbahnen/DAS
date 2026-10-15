// migration-layout.property.test.mjs
//
// Property test for the one-time migration of existing Flavor_Folders from the
// legacy BARE layout (files directly under `.<flavor>/<rest>`, which mapped to
// `lib/<rest>`) to the package-root layout (files under a Flavor_Source_Root,
// i.e. `.<flavor>/lib/<rest>`).
//
// Feature: flavor-code-switching, Property 24: Migration relocates every flavor
// file under a lib/ source root without altering content.
//
// The production migration was a one-off `git mv`, so there is no production
// function to exercise. We model the migration transform as a pure local helper
// `migrateLegacyFlavorTree(files)` that maps each legacy relative path `<rest>`
// to `lib/<rest>`, and assert:
//   1. After the transform, every legacy file at `.<flavor>/<rest>` now lives at
//      `.<flavor>/lib/<rest>` with BYTE-IDENTICAL content.
//   2. No migrated file remains directly under the flavor folder outside a
//      Flavor_Source_Root — every migrated path's first segment is `lib`.
//   3. A subsequent switch over the MIGRATED tree reproduces the IDENTICAL
//      `lib/` target set that the legacy layout would have produced: building a
//      temp-dir repo whose component flavor folder holds `.<flavor>/lib/<rest>`
//      and running the real switch yields activated targets at
//      `<component>/lib/<rest>` that exactly match the original legacy `<rest>`
//      set, byte-for-byte.
//
// Parts 1 and 2 are a pure transform check; part 3 is an on-disk switch check
// (buildRepo + main + removeTempDir). buildRepo writes `flavors[flavor]` keys
// verbatim under `.<flavor>/`, so the migrated keys (`lib/<rest>`) encode the
// package-root layout directly.
//
// Validates: Requirements 14.1, 14.2, 14.3
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
function randomName(minLen = 1, maxLen = 8) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}

/** Random file content — may include empty, text, and non-ASCII (unicode) bytes. */
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

/**
 * Model of the one-time flavor-folder migration as a PURE function.
 *
 * Input: the LEGACY-layout flavor files, keyed by their flavor-folder-relative
 * POSIX path `<rest>` (i.e. placed directly under `.<flavor>/<rest>`, the
 * pre-migration layout that mapped to `lib/<rest>`).
 *
 * Output: the MIGRATED flavor files, keyed by `lib/<rest>` (so each lands under
 * the `lib` Flavor_Source_Root at `.<flavor>/lib/<rest>`), with content copied
 * verbatim.
 *
 * @param {Record<string,string>} files legacy `<rest>` → content
 * @returns {Record<string,string>} migrated `lib/<rest>` → content
 */
function migrateLegacyFlavorTree(files) {
  const migrated = {};
  for (const [rest, content] of Object.entries(files)) {
    migrated[`lib/${rest}`] = content;
  }
  return migrated;
}

/**
 * Build a random set of LEGACY-layout flavor files placed directly under the
 * flavor folder, keyed by their flavor-folder-relative POSIX path `<rest>`
 * (no leading source root). Nested directories are exercised and files share
 * intermediate dirs via a small pool. Guarantees at least one file.
 * @returns {Record<string,string>} `<rest>` → content
 */
function randomLegacyTree() {
  const tree = {};

  // Pool of nested dir prefixes (incl. the empty prefix) so files share dirs.
  const dirPool = [''];
  const extra = randInt(3);
  for (let i = 0; i < extra; i++) {
    const depth = randIntRange(1, 3);
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 5));
    dirPool.push(segs.join('/'));
  }

  const fileCount = randIntRange(1, 6);
  let attempts = 0;
  let placed = 0;
  while (placed < fileCount && attempts < fileCount * 10) {
    attempts++;
    const dir = pick(dirPool);
    const rest = `${dir === '' ? '' : `${dir}/`}${randomName(1, 8)}.dart`;
    if (Object.prototype.hasOwnProperty.call(tree, rest)) continue;
    tree[rest] = randomContent();
    placed++;
  }
  return tree;
}

/** Silence console output from main() while still exercising the real path. */
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

test('Property 24: migration relocates every flavor file under lib/ byte-identically and the switch reproduces the identical lib/ target set', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const flavor = pick(FLAVORS);
    const componentName = `comp_${i}_${randomName(2, 6)}`;

    // Generate a legacy-layout flavor folder: files directly under `.<flavor>/`.
    const legacy = randomLegacyTree();
    const legacyKeys = Object.keys(legacy);

    const ctx = `iter=${i} flavor='${flavor}' component='${componentName}' files=${legacyKeys.length}`;

    // ---- Part 1 + 2: PURE transform checks (no I/O) ------------------------
    const migrated = migrateLegacyFlavorTree(legacy);
    const migratedKeys = Object.keys(migrated);

    // Same number of files; no file dropped or duplicated.
    assert.equal(
      migratedKeys.length,
      legacyKeys.length,
      `migration must preserve the file count (${ctx})`,
    );

    // (1) Every legacy `<rest>` is now at `lib/<rest>` with identical content;
    // (2) every migrated path's first segment is the `lib` source root.
    for (const rest of legacyKeys) {
      const migratedKey = `lib/${rest}`;
      assert.ok(
        Object.prototype.hasOwnProperty.call(migrated, migratedKey),
        `legacy file '${rest}' must relocate to '${migratedKey}' (${ctx})`,
      );
      assert.equal(
        migrated[migratedKey],
        legacy[rest],
        `content of '${rest}' must be byte-identical after migration (${ctx})`,
      );
    }
    for (const key of migratedKeys) {
      const firstSegment = key.split('/')[0];
      assert.equal(
        firstSegment,
        'lib',
        `migrated path '${key}' must live under the lib/ source root (${ctx})`,
      );
    }

    // ---- Part 3: on-disk switch reproduces the identical lib/ target set ----
    const repoRoot = await makeTempDir('flavor-migration-prop-');
    try {
      // Seed the component's flavor folder with the MIGRATED tree. buildRepo
      // writes each `flavors[flavor]` key verbatim under `.<flavor>/`, so the
      // keys `lib/<rest>` produce the package-root layout on disk.
      await buildRepo(repoRoot, {
        components: [
          {
            name: componentName,
            lib: { 'placeholder.dart': '// placeholder\n' },
            flavors: { [flavor]: migrated },
          },
        ],
      });

      const code = withSilencedConsole(() =>
        main(['node', 'switch-flavor.mjs', flavor], { repoRoot }),
      );
      assert.equal(code, 0, `switch over the migrated tree must succeed (${ctx})`);

      // The legacy layout would have activated exactly `<component>/lib/<rest>`
      // for each legacy `<rest>`. Assert the migrated switch reproduces exactly
      // that set, byte-for-byte.
      for (const rest of legacyKeys) {
        const targetAbs = path.join(repoRoot, componentName, 'lib', ...rest.split('/'));
        assert.ok(
          fs.existsSync(targetAbs),
          `activated target lib/${rest} must exist after switch (${ctx})`,
        );
        const activated = await fsp.readFile(targetAbs);
        const expected = Buffer.from(legacy[rest]);
        assert.ok(
          activated.equals(expected),
          `activated lib/${rest} must be byte-identical to the legacy source (${ctx})`,
        );
      }

      // And the manifest's target set is EXACTLY the legacy `lib/<rest>` set —
      // no extra targets slipped in from a stray relocation.
      const manifestPath = path.join(repoRoot, '.flavor-manifest.json');
      const manifest = JSON.parse(await fsp.readFile(manifestPath, 'utf8'));
      const expectedTargets = legacyKeys
        .map((rest) => `${componentName}/lib/${rest}`)
        .sort();
      const actualTargets = manifest.files.map((e) => e.path).sort();
      assert.deepEqual(
        actualTargets,
        expectedTargets,
        `switch must activate exactly the legacy lib/ target set (${ctx})`,
      );
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
