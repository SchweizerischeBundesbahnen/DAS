// cross-flavor-base-preservation.property.test.mjs
//
// Regression property test for spec task 40: switching flavor A→B WITHOUT an
// intervening restore, then restore-base, MUST leave every committed base file
// intact (none deleted), remove only genuinely new flavor files, and clear the
// manifest + Base_Backup_Directory.
//
// Historic bug: a second switch deleted the previous flavor's targets BEFORE
// copying the new flavor, so the base files (overwritten by A) were gone from
// lib/ at B's copy time → classified New_File_Entry (overwrote:false) with no
// backup → a later restore-base DELETED them. The fix makes `switch` restore the
// base first when a prior switch is active, so classification is always against
// the true base.
//
// Feature: flavor-code-switching, Property 14 (switch→restore round-trip — cross-flavor case)
// Validates: Requirements 5.1, 5.2, 10.1, 11.1, 11.2, 11.4
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

import { main, restoreBase, MANIFEST_FILENAME, BASE_BACKUP_DIRNAME } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

const ITERATIONS = 120; // >= 100 minimum per the plan.

function randInt(maxExclusive) { return Math.floor(Math.random() * maxExclusive); }
function randIntRange(min, max) { return min + randInt(max - min + 1); }
function pick(arr) { return arr[randInt(arr.length)]; }

function randomName(minLen = 2, maxLen = 7) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  const len = randIntRange(minLen, maxLen);
  let s = '';
  for (let i = 0; i < len; i++) s += alphabet[randInt(alphabet.length)];
  return s;
}
function randomContent(tag) {
  return `// ${tag}\nvar v = ${randInt(1_000_000)};\n`;
}
function distinctRests(count, used) {
  const out = [];
  let attempts = 0;
  while (out.length < count && attempts < count * 40) {
    attempts++;
    const depth = randInt(3);
    const segs = [];
    for (let d = 0; d < depth; d++) segs.push(randomName(1, 5));
    segs.push(`${randomName(1, 7)}.dart`);
    const rel = segs.join('/');
    if (used.has(rel)) continue;
    used.add(rel);
    out.push(rel);
  }
  return out;
}
function sha(abs) {
  try { return crypto.createHash('sha256').update(fs.readFileSync(abs)).digest('hex'); }
  catch (err) { if (err && err.code === 'ENOENT') return undefined; throw err; }
}
function withSilencedConsole(fn) {
  const log = console.log, error = console.error;
  console.log = () => {}; console.error = () => {};
  try { return fn(); } finally { console.log = log; console.error = error; }
}

test('Property 14 (cross-flavor): switch A then B (no restore between) then restore-base keeps the base intact', async () => {
  for (let i = 0; i < ITERATIONS; i++) {
    const repoRoot = await makeTempDir('flavor-cross-flavor-');
    try {
      const flavorA = 'dev';
      const flavorB = 'inte';
      const comp = `comp_${i}_${randomName(2, 5)}`;
      const used = new Set();

      // Base files that BOTH flavors overwrite (the regression paths).
      const shared = distinctRests(randIntRange(1, 4), used);
      // Base files only A overwrites.
      const aOnlyBase = distinctRests(randInt(3), used);
      // New-only files that each flavor ADDS (no base file).
      const aNew = distinctRests(randInt(3), used);
      const bNew = distinctRests(randInt(3), used);

      // Seed base content under lib/ for all base paths (shared + aOnlyBase).
      const libSeed = {};
      const baseContent = new Map(); // target -> original base content
      for (const rest of [...shared, ...aOnlyBase]) {
        const c = randomContent(`base ${comp}/lib/${rest}`);
        libSeed[rest] = c;
        baseContent.set(`${comp}/lib/${rest}`, c);
      }

      // Flavor A folder: overwrites shared + aOnlyBase, adds aNew.
      const flavorAFiles = {};
      for (const rest of [...shared, ...aOnlyBase]) flavorAFiles[`lib/${rest}`] = randomContent(`A ${rest}`);
      for (const rest of aNew) flavorAFiles[`lib/${rest}`] = randomContent(`A-new ${rest}`);

      // Flavor B folder: overwrites shared (same base paths), adds bNew.
      const flavorBFiles = {};
      for (const rest of shared) flavorBFiles[`lib/${rest}`] = randomContent(`B ${rest}`);
      for (const rest of bNew) flavorBFiles[`lib/${rest}`] = randomContent(`B-new ${rest}`);

      await buildRepo(repoRoot, {
        components: [
          { name: comp, lib: libSeed, flavors: { [flavorA]: flavorAFiles, [flavorB]: flavorBFiles } },
        ],
      });

      const ctx = `iter=${i} comp=${comp} shared=${shared.length} aOnly=${aOnlyBase.length} aNew=${aNew.length} bNew=${bNew.length}`;

      // Snapshot the original base.
      const baseSnapshot = new Map();
      for (const [target, content] of baseContent) {
        baseSnapshot.set(target, crypto.createHash('sha256').update(Buffer.from(content)).digest('hex'));
      }

      // Switch A, then B WITHOUT an intervening restore.
      assert.equal(withSilencedConsole(() => main(['node', 'x', flavorA], { repoRoot })), 0, `switch A must succeed (${ctx})`);
      assert.equal(withSilencedConsole(() => main(['node', 'x', flavorB], { repoRoot })), 0, `switch B must succeed (${ctx})`);

      // Restore base.
      assert.equal(withSilencedConsole(() => restoreBase(repoRoot)), 0, `restoreBase must succeed (${ctx})`);

      // Every committed base file is byte-identical to the original — NONE deleted.
      for (const [target, expectedHash] of baseSnapshot) {
        const abs = path.join(repoRoot, target);
        assert.ok(fs.existsSync(abs), `base file must NOT be deleted: ${target} (${ctx})`);
        assert.equal(sha(abs), expectedHash, `base file must be byte-identical: ${target} (${ctx})`);
      }

      // New-only flavor files are gone after restore.
      for (const rest of [...aNew, ...bNew]) {
        const abs = path.join(repoRoot, comp, 'lib', rest);
        assert.ok(!fs.existsSync(abs), `new-only flavor file must be removed: ${comp}/lib/${rest} (${ctx})`);
      }

      // Manifest cleared, backup dir empty/removed.
      assert.ok(!fs.existsSync(path.join(repoRoot, MANIFEST_FILENAME)), `manifest must be cleared (${ctx})`);
      const backupDir = path.join(repoRoot, BASE_BACKUP_DIRNAME);
      if (fs.existsSync(backupDir)) {
        assert.equal(fs.readdirSync(backupDir).length, 0, `backup dir must be empty (${ctx})`);
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});

test('Property 14 (same-flavor twice): switch A then A again then restore-base round-trips the base', async () => {
  for (let i = 0; i < 40; i++) {
    const repoRoot = await makeTempDir('flavor-same-twice-');
    try {
      const flavor = 'dev';
      const comp = `c_${i}_${randomName(2, 4)}`;
      const used = new Set();
      const baseRests = distinctRests(randIntRange(1, 4), used);

      const libSeed = {};
      const baseContent = new Map();
      for (const rest of baseRests) {
        const c = randomContent(`base ${rest}`);
        libSeed[rest] = c;
        baseContent.set(`${comp}/lib/${rest}`, c);
      }
      const flavorFiles = {};
      for (const rest of baseRests) flavorFiles[`lib/${rest}`] = randomContent(`flavor ${rest}`);

      await buildRepo(repoRoot, {
        components: [{ name: comp, lib: libSeed, flavors: { [flavor]: flavorFiles } }],
      });

      const ctx = `iter=${i} comp=${comp}`;
      assert.equal(withSilencedConsole(() => main(['node', 'x', flavor], { repoRoot })), 0, `first switch ok (${ctx})`);
      assert.equal(withSilencedConsole(() => main(['node', 'x', flavor], { repoRoot })), 0, `second switch ok (${ctx})`);
      assert.equal(withSilencedConsole(() => restoreBase(repoRoot)), 0, `restore ok (${ctx})`);

      for (const [target, content] of baseContent) {
        const abs = path.join(repoRoot, target);
        assert.ok(fs.existsSync(abs), `base must survive A→A→restore: ${target} (${ctx})`);
        assert.equal(fs.readFileSync(abs, 'utf8'), content, `base content intact: ${target} (${ctx})`);
      }
    } finally {
      await removeTempDir(repoRoot);
    }
  }
});
