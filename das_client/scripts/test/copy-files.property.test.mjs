// copy-files.property.test.mjs
//
// Property test for planCopy + copyFiles copy fidelity and structure
// preservation across BOTH recognized Flavor_Source_Roots (`lib/` and `test/`).
//
// Feature: flavor-code-switching, Property 2: Copy fidelity and structure
// preservation (both source roots): for a flavor folder that is a partial
// mirror of the component root — carrying files under `.<flavor>/lib/...` and
// `.<flavor>/test/...` — after a copy every source file at
// `<component>/.<flavor>/<root>/<relpath>` (root ∈ {lib,test}) exists at
// `<component>/<root>/<relpath>` with byte-identical content, whether or not a
// file already existed at the target (overwrite included). Stray entries OUTSIDE
// any source root (directly under `.<flavor>/` or under an unrecognized
// top-level dir such as `.<flavor>/bin/...`) are IGNORED and copied nowhere
// (Req 1.6). copyFiles returns one `{ path, overwrote }` entry per written
// target — exactly the mapped repo-relative POSIX target paths, with `overwrote`
// reflecting pre-existence.
//
// Validates: Requirements 1.3, 1.4, 1.6
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { planCopy, copyFiles, FLAVORS } from '../switch-flavor.mjs';
import {
  makeTempDir,
  removeTempDir,
  buildRepo,
  buildSourceRootTree,
  SOURCE_ROOTS,
} from './helpers.mjs';

const ITERATIONS = 150; // >= 100 minimum per the plan.

/** Random integer in [0, maxExclusive). */
function randInt(maxExclusive) {
  return Math.floor(Math.random() * maxExclusive);
}

/** Random integer in [min, max]. */
function randIntRange(min, max) {
  return min + randInt(max - min + 1);
}

/** Produce a random lowercase identifier of the given length range. */
function randomName(minLen = 1, maxLen = 8) {
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

// Random hooks fed to the shared source-root fixture builder so this suite keeps
// owning its own name/content/iteration conventions.
const random = {
  name: () => randomName(1, 6),
  content: randomContent,
  int: randInt,
};

test('Property 2: planCopy + copyFiles preserves nested structure byte-identically across lib/ and test/, incl. overwrite, ignoring strays', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-copy-prop-');
    try {
      const flavor = FLAVORS[randInt(FLAVORS.length)];
      const componentName = randomName(3, 10);

      // Seed a flavor folder spread across BOTH source roots (lib/ + test/) plus
      // the occasional stray entry outside any source root (Req 1.6).
      const { tree, mapped, strays } = buildSourceRootTree(random);

      // Decide, per MAPPED source file, whether to pre-create a conflicting file
      // at its component target with DIFFERENT content to prove overwrite. The
      // target is <component>/<root>/<rest> for a `.<flavor>/<root>/<rest>`
      // source, so pre-seed lib/ and test/ via the component's `lib`/`test`.
      const preexistingLib = {}; // keyed by lib-relative rest
      const preexistingTest = {}; // keyed by test-relative rest
      for (const rel of Object.keys(mapped)) {
        const slash = rel.indexOf('/');
        const root = rel.slice(0, slash); // 'lib' | 'test'
        const rest = rel.slice(slash + 1);
        if (Math.random() < 0.5) {
          const conflicting = `PREEXISTING::${mapped[rel]}::${randomName(4, 8)}`;
          if (root === 'lib') preexistingLib[rest] = conflicting;
          else preexistingTest[rest] = conflicting;
        }
      }

      await buildRepo(repoRoot, {
        components: [
          {
            name: componentName,
            lib: preexistingLib,
            test: preexistingTest,
            flavors: { [flavor]: tree },
          },
        ],
      });

      const componentDir = path.join(repoRoot, componentName);

      // Build the plan and run the copy.
      const plan = planCopy(componentDir, flavor, repoRoot);
      const written = copyFiles(plan, repoRoot);

      const ctx = `iter=${i} flavor='${flavor}' component='${componentName}' mapped=${Object.keys(mapped).length} strays=${Object.keys(strays).length}`;

      // The plan must cover exactly the MAPPED flavor source files (one entry
      // each) — stray entries contribute nothing (Req 1.6).
      assert.equal(
        plan.length,
        Object.keys(mapped).length,
        `plan must have one entry per mapped flavor source file (${ctx})`,
      );

      // Expected repo-relative POSIX targets: <component>/<root>/<rest>, derived
      // directly from each mapped `<root>/<rest>` key.
      const expectedTargets = Object.keys(mapped)
        .map((rel) => `${componentName}/${rel}`)
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
        const rel = entry.path.slice(`${componentName}/`.length); // <root>/<rest>
        const slash = rel.indexOf('/');
        const root = rel.slice(0, slash);
        const rest = rel.slice(slash + 1);
        const preExisted =
          root === 'lib'
            ? Object.prototype.hasOwnProperty.call(preexistingLib, rest)
            : Object.prototype.hasOwnProperty.call(preexistingTest, rest);
        assert.equal(
          entry.overwrote,
          preExisted,
          `overwrote flag for ${entry.path} must match pre-existence (${ctx})`,
        );
      }

      // Every MAPPED flavor source file now exists at its <root>/ target with
      // byte-identical content — overwrite case included.
      for (const rel of Object.keys(mapped)) {
        const slash = rel.indexOf('/');
        const root = rel.slice(0, slash);
        const rest = rel.slice(slash + 1);

        const sourceAbs = path.join(componentDir, `.${flavor}`, root, rest);
        const targetAbs = path.join(componentDir, root, rest);

        assert.ok(
          fs.existsSync(targetAbs),
          `target must exist at ${root}/${rest} (${ctx})`,
        );

        const srcBuf = await fsp.readFile(sourceAbs);
        const dstBuf = await fsp.readFile(targetAbs);
        assert.ok(
          srcBuf.equals(dstBuf),
          `content at ${root}/${rest} must be byte-identical to flavor source (${ctx})`,
        );

        // Where we pre-seeded a conflicting file, prove it was overwritten.
        const pre = root === 'lib' ? preexistingLib[rest] : preexistingTest[rest];
        if (pre !== undefined) {
          assert.notEqual(
            dstBuf.toString('utf8'),
            pre,
            `preexisting target at ${root}/${rest} must have been overwritten (${ctx})`,
          );
        }
      }

      // NO stray entry (outside a source root) is copied anywhere (Req 1.6). A
      // stray never maps to a <root>/<rest> target, so neither its would-be
      // "directly under the component" path nor any unrecognized-dir path exists
      // among the written targets or on disk under the component.
      for (const strayRel of Object.keys(strays)) {
        // The stray source itself still lives under the flavor folder…
        const strayFlavorPath = `${componentName}/.${flavor}/${strayRel}`;
        assert.ok(
          !writtenPaths.includes(strayFlavorPath),
          `stray flavor entry ${strayRel} must not be a written target (${ctx})`,
        );
        // …and it must NOT have been copied to a component-relative location.
        const strayComponentPath = path.join(componentDir, strayRel);
        if (!Object.prototype.hasOwnProperty.call(mapped, strayRel)) {
          assert.ok(
            !fs.existsSync(strayComponentPath),
            `stray entry ${strayRel} must not be copied to the component root (${ctx})`,
          );
        }
      }

      // Nothing landed outside the two recognized source roots: every written
      // target's first segment after the component is a recognized source root.
      for (const p of writtenPaths) {
        const rel = p.slice(`${componentName}/`.length);
        const root = rel.slice(0, rel.indexOf('/'));
        assert.ok(
          SOURCE_ROOTS.includes(root),
          `written target ${p} must live under a recognized source root (${ctx})`,
        );
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
