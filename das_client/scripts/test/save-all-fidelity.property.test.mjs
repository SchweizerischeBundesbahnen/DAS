// save-all-fidelity.property.test.mjs
//
// Property test for saveAllToFlavor copy fidelity and path derivation.
//
// Feature: flavor-code-switching, Property 19: Save-all copies every present
// changed lib/ or test/ file to the derived flavor path: for a random flavor and
// a random set of present (on-disk) Git-changed <component>/<root>/<rest> files
// (root ∈ {lib, test}), saveAllToFlavor produces a byte-identical copy at the
// derived destination <component>/.<flavor>/<root>/<rest> (deriveFlavorDest),
// leaves every source byte-identical (COPY, not move), and produces NO flavor
// copy for changed paths that are not under a <component>/lib/ or <component>/test/
// source root.
//
// Validates: Requirements 13.1, 13.2, 13.3
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.
//
// Git faking: saveAllToFlavor calls gitChangedSourceFiles(repoRoot, spawn), which
// first runs `git -C <repoRoot> rev-parse --show-toplevel` and then
// `git -C <repoRoot> status --porcelain -z`. gitChangedSourceFiles classifies each
// parsed path present/deleted by ON-DISK EXISTENCE under repoRoot and filters to
// <component>/lib/<rest> and <component>/test/<rest> paths. We drive it
// deterministically by creating the real files on disk (so existence sees them as
// present) and supplying a fake spawn that returns toplevel === repoRoot (so
// porcelain paths are repoRoot-relative) and a NUL-separated porcelain -z string
// listing our changed paths.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveAllToFlavor, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo, SOURCE_ROOTS } from './helpers.mjs';

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
    let s = '';
    const alphabet = 'abcdef ghij\nklmno\tpqrst0123456789';
    for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
    return s;
  }
  let s = '';
  for (let i = 0; i < len; i++) s += String.fromCharCode(randIntRange(0, 0x2fff));
  return s;
}

/** Build a random nested relative POSIX path ending in a .dart file (non-empty). */
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

/**
 * Build a fake `spawn` matching the gitChangedSourceFiles call contract:
 *   - rev-parse --show-toplevel  → toplevel === repoRoot (so porcelain paths are
 *     repoRoot-relative)
 *   - status --porcelain -z      → the given NUL-separated porcelain stream
 * The subcommand is detected by inspecting the args array.
 *
 * @param {string} repoRoot
 * @param {string} porcelain NUL-separated porcelain -z stdout
 */
function makeFakeSpawn(repoRoot, porcelain) {
  return (cmd, args /*, opts */) => {
    if (Array.isArray(args) && args.includes('rev-parse')) {
      return { status: 0, stdout: `${repoRoot}\n`, error: undefined };
    }
    if (Array.isArray(args) && args.includes('status')) {
      return { status: 0, stdout: porcelain, error: undefined };
    }
    // Unexpected call — surface as a hard git failure so the test notices.
    return { status: 1, stdout: '', error: new Error(`unexpected git call: ${cmd} ${args}`) };
  };
}

/**
 * Build a porcelain -z record `XY<space>path\0`. Porcelain v1 -z: each record is
 * the two-char status code, a space, then the path, terminated by a NUL.
 * @param {string} code two-char XY status code (e.g. '??', ' M')
 * @param {string} p repoRoot-relative POSIX path
 */
function porcelainRecord(code, p) {
  return `${code} ${p}\0`;
}

test("Feature: flavor-code-switching, Property 19: Save-all copies every present changed lib/ or test/ file to the derived flavor path", async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-all-prop-');
    try {
      const flavor = pick(FLAVORS);

      // 1..3 components, each with a random set of changed source files spread
      // across BOTH recognized source roots (lib/ and test/).
      const componentCount = randIntRange(1, 3);
      const components = [];
      // present source changes: { component, root, rest, relPosix, content }
      const srcChanges = [];
      // non-source changes that must be filtered out: repoRoot-relative POSIX path
      const nonSrcChanges = [];
      const usedComponentNames = new Set();
      const usedRelPaths = new Set();

      for (let c = 0; c < componentCount; c++) {
        let componentName = randomName(3, 10);
        while (usedComponentNames.has(componentName)) componentName = randomName(3, 10);
        usedComponentNames.add(componentName);

        const libFiles = {};
        const testFiles = {};

        // Seed each recognized source root with >= 1 changed file so BOTH roots
        // are exercised every iteration.
        for (const root of SOURCE_ROOTS) {
          const fileCount = randIntRange(1, 3);
          for (let f = 0; f < fileCount; f++) {
            let rest = randomRest();
            let relPosix = `${componentName}/${root}/${rest}`;
            let guard = 0;
            while (usedRelPaths.has(relPosix) && guard < 20) {
              rest = randomRest();
              relPosix = `${componentName}/${root}/${rest}`;
              guard++;
            }
            if (usedRelPaths.has(relPosix)) continue;
            usedRelPaths.add(relPosix);

            const content = randomContent();
            if (root === 'lib') libFiles[rest] = content;
            else testFiles[rest] = content;
            srcChanges.push({ component: componentName, root, rest, relPosix, content });
          }
        }

        const componentSpec = { name: componentName, lib: libFiles, test: testFiles };

        // In ~half the iterations, pre-create a DIFFERENT-content file at the
        // flavor destination for one of this component's changed files to exercise
        // the overwrite path (Req 13.3 — overwrite-with-report). The flavor seed
        // key is written verbatim, so prefix it with the source root.
        if (Math.random() < 0.5 && srcChanges.length > 0) {
          const victim = srcChanges[srcChanges.length - 1];
          if (victim.component === componentName) {
            componentSpec.flavors = {
              [flavor]: { [`${victim.root}/${victim.rest}`]: `STALE::${randomName(4, 8)}` },
            };
          }
        }

        components.push(componentSpec);

        // Add a NON-source changed path for this component that must be filtered
        // out: a file directly under the component (no lib/ or test/ root).
        nonSrcChanges.push(`${componentName}/${randomName(2, 6)}.dart`);
      }

      // Also add a root-level non-source changed file.
      nonSrcChanges.push(`${randomName(2, 8)}.dart`);

      await buildRepo(repoRoot, { components });

      // Create the non-source changed files on disk too (they are "present"
      // changes, but must still be filtered out because they are not under a
      // <component>/lib/ or <component>/test/ source root).
      for (const nonSrcRel of nonSrcChanges) {
        const abs = path.join(repoRoot, nonSrcRel);
        await fsp.mkdir(path.dirname(abs), { recursive: true });
        await fsp.writeFile(abs, randomContent());
      }

      // Build the porcelain -z stream: a mix of untracked (??) and modified ( M)
      // records for every source change and every non-source change, random order.
      const allRecords = [];
      for (const ch of srcChanges) {
        const code = Math.random() < 0.5 ? '??' : ' M';
        allRecords.push(porcelainRecord(code, ch.relPosix));
      }
      for (const nonSrcRel of nonSrcChanges) {
        const code = Math.random() < 0.5 ? '??' : ' M';
        allRecords.push(porcelainRecord(code, nonSrcRel));
      }
      // Shuffle records.
      for (let k = allRecords.length - 1; k > 0; k--) {
        const j = randInt(k + 1);
        [allRecords[k], allRecords[j]] = [allRecords[j], allRecords[k]];
      }
      const porcelain = allRecords.join('');

      const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

      const ctx = `iter=${i} flavor='${flavor}' srcChanges=${srcChanges.length} nonSrc=${nonSrcChanges.length}`;

      // Capture source bytes before the run.
      const srcBytesBefore = new Map();
      for (const ch of srcChanges) {
        srcBytesBefore.set(ch.relPosix, await fsp.readFile(path.join(repoRoot, ch.relPosix)));
      }

      // Run save-all with console silenced; it must succeed (exit code 0).
      const code = withSilencedConsole(() =>
        saveAllToFlavor(repoRoot, flavor, { spawn: fakeSpawn }),
      );
      assert.equal(code, 0, `saveAllToFlavor must return 0 (${ctx})`);

      // For every present source file (lib/ or test/), a byte-identical copy
      // exists at the derived flavor destination <component>/.<flavor>/<root>/<rest>
      // AND the source under <root>/ is unchanged (COPY, not move).
      for (const ch of srcChanges) {
        const destRel = `${ch.component}/.${flavor}/${ch.root}/${ch.rest}`;
        const destAbs = path.join(repoRoot, destRel);
        const srcAbs = path.join(repoRoot, ch.relPosix);

        assert.ok(
          fs.existsSync(srcAbs),
          `source must still exist at ${ch.relPosix} (${ctx})`,
        );
        const srcAfter = await fsp.readFile(srcAbs);
        assert.ok(
          srcBytesBefore.get(ch.relPosix).equals(srcAfter),
          `source at ${ch.relPosix} must be byte-identical to before (${ctx})`,
        );

        assert.ok(
          fs.existsSync(destAbs),
          `derived flavor copy must exist at ${destRel} (${ctx})`,
        );
        const dstAfter = await fsp.readFile(destAbs);
        assert.ok(
          srcAfter.equals(dstAfter),
          `flavor copy at ${destRel} must be byte-identical to the source (${ctx})`,
        );
      }

      // The non-source changed paths produced NO flavor copy anywhere.
      for (const nonSrcRel of nonSrcChanges) {
        // A path like `<component>/foo.dart` has no lib/ or test/ source root, so
        // deriveFlavorDest rejects it and no `<component>/.<flavor>/...` copy is
        // created. Assert the specific would-be sibling path does not exist.
        const parts = nonSrcRel.split('/');
        if (parts.length >= 2) {
          const wouldBe = path.join(repoRoot, parts[0], `.${flavor}`, ...parts.slice(1));
          assert.ok(
            !fs.existsSync(wouldBe),
            `non-source path ${nonSrcRel} must NOT produce a flavor copy (${ctx})`,
          );
        }
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
