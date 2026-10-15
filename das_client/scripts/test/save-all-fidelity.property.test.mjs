// save-all-fidelity.property.test.mjs
//
// Property test for saveAllToFlavor copy fidelity and path derivation.
//
// Feature: flavor-code-switching, Property 19: Save-all copies every present
// changed lib/ file to the derived flavor path: for a random flavor and a random
// set of present (on-disk) Git-changed <component>/lib/<rest> files, saveAllToFlavor
// produces a byte-identical copy at the derived destination <component>/<flavor>/<rest>
// (deriveFlavorDest), leaves every lib/ source byte-identical (COPY, not move), and
// produces NO flavor copy for changed paths that are not <component>/lib/<rest>.
//
// Validates: Requirements 13.1, 13.2, 13.3
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.
//
// Git faking: saveAllToFlavor calls gitChangedLibFiles(repoRoot, spawn), which
// first runs `git -C <repoRoot> rev-parse --show-toplevel` and then
// `git -C <repoRoot> status --porcelain -z`. gitChangedLibFiles classifies each
// parsed path present/deleted by ON-DISK EXISTENCE under repoRoot and filters to
// <component>/lib/<rest> paths. We drive it deterministically by creating the real
// files on disk (so existence sees them as present) and supplying a fake spawn
// that returns toplevel === repoRoot (so porcelain paths are repoRoot-relative) and
// a NUL-separated porcelain -z string listing our changed paths.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { saveAllToFlavor, FLAVORS } from '../switch-flavor.mjs';
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
 * Build a fake `spawn` matching the gitChangedLibFiles call contract:
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

test("Feature: flavor-code-switching, Property 19: Save-all copies every present changed lib/ file to the derived flavor path", async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-save-all-prop-');
    try {
      const flavor = pick(FLAVORS);

      // 1..3 components, each with a random set of changed lib/ files.
      const componentCount = randIntRange(1, 3);
      const components = [];
      // present lib changes: { rel, content, component }
      const libChanges = [];
      // non-lib changes that must be filtered out: repoRoot-relative POSIX path
      const nonLibChanges = [];
      const usedComponentNames = new Set();
      const usedRelPaths = new Set();

      for (let c = 0; c < componentCount; c++) {
        let componentName = randomName(3, 10);
        while (usedComponentNames.has(componentName)) componentName = randomName(3, 10);
        usedComponentNames.add(componentName);

        const libFiles = {};
        const fileCount = randIntRange(1, 4);
        for (let f = 0; f < fileCount; f++) {
          let rest = randomRest();
          const relPosix = `${componentName}/lib/${rest}`;
          while (usedRelPaths.has(relPosix)) {
            rest = randomRest();
          }
          const dedupRel = `${componentName}/lib/${rest}`;
          if (usedRelPaths.has(dedupRel)) continue;
          usedRelPaths.add(dedupRel);

          const content = randomContent();
          libFiles[rest] = content;
          libChanges.push({ component: componentName, rest, relPosix: dedupRel, content });
        }

        const componentSpec = { name: componentName, lib: libFiles };

        // In ~half the iterations, pre-create a DIFFERENT-content file at the
        // flavor destination for one of this component's changed files to exercise
        // the overwrite path (Req 13.3 — overwrite-with-report).
        if (Math.random() < 0.5 && libChanges.length > 0) {
          const victim = libChanges[libChanges.length - 1];
          if (victim.component === componentName) {
            componentSpec.flavors = {
              [flavor]: { [victim.rest]: `STALE::${randomName(4, 8)}` },
            };
          }
        }

        components.push(componentSpec);

        // Add a NON-lib changed path for this component that must be filtered out:
        // a test/ file (not under lib/).
        nonLibChanges.push(`${componentName}/test/${randomName(2, 6)}.dart`);
      }

      // Also add a root-level non-lib changed file.
      nonLibChanges.push(`${randomName(2, 8)}.dart`);

      await buildRepo(repoRoot, { components });

      // Create the non-lib changed files on disk too (they are "present" changes,
      // but must still be filtered out because they are not <component>/lib/<rest>).
      for (const nonLibRel of nonLibChanges) {
        const abs = path.join(repoRoot, nonLibRel);
        await fsp.mkdir(path.dirname(abs), { recursive: true });
        await fsp.writeFile(abs, randomContent());
      }

      // Build the porcelain -z stream: a mix of untracked (??) and modified ( M)
      // records for every lib change and every non-lib change, in random order.
      const allRecords = [];
      for (const ch of libChanges) {
        const code = Math.random() < 0.5 ? '??' : ' M';
        allRecords.push(porcelainRecord(code, ch.relPosix));
      }
      for (const nonLibRel of nonLibChanges) {
        const code = Math.random() < 0.5 ? '??' : ' M';
        allRecords.push(porcelainRecord(code, nonLibRel));
      }
      // Shuffle records.
      for (let k = allRecords.length - 1; k > 0; k--) {
        const j = randInt(k + 1);
        [allRecords[k], allRecords[j]] = [allRecords[j], allRecords[k]];
      }
      const porcelain = allRecords.join('');

      const fakeSpawn = makeFakeSpawn(repoRoot, porcelain);

      const ctx = `iter=${i} flavor='${flavor}' libChanges=${libChanges.length} nonLib=${nonLibChanges.length}`;

      // Capture source bytes before the run.
      const srcBytesBefore = new Map();
      for (const ch of libChanges) {
        srcBytesBefore.set(ch.relPosix, await fsp.readFile(path.join(repoRoot, ch.relPosix)));
      }

      // Run save-all with console silenced; it must succeed (exit code 0).
      const code = withSilencedConsole(() =>
        saveAllToFlavor(repoRoot, flavor, { spawn: fakeSpawn }),
      );
      assert.equal(code, 0, `saveAllToFlavor must return 0 (${ctx})`);

      // For every present lib file, a byte-identical copy exists at the derived
      // flavor destination AND the source under lib/ is unchanged (COPY, not move).
      for (const ch of libChanges) {
        const destRel = `${ch.component}/${flavor}/${ch.rest}`;
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

      // The non-lib changed paths produced NO flavor copy anywhere.
      for (const nonLibRel of nonLibChanges) {
        // A non-lib path like `<component>/test/foo.dart` must not have spawned a
        // `<component>/<flavor>/...` copy. Assert there is no flavor-folder file
        // mirroring the non-lib path's basename under any flavor folder.
        // Concretely: the derived path a lib-filter would reject should not exist.
        // Component/test/foo.dart has no <component>/lib/ prefix, so no flavor dest.
        // We assert the specific would-be sibling path does not exist.
        const parts = nonLibRel.split('/');
        if (parts.length >= 2 && parts[1] === 'test') {
          const wouldBe = path.join(repoRoot, parts[0], flavor, ...parts.slice(2));
          assert.ok(
            !fs.existsSync(wouldBe),
            `non-lib path ${nonLibRel} must NOT produce a flavor copy at ${parts[0]}/${flavor}/${parts.slice(2).join('/')} (${ctx})`,
          );
        }
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
