// delete-targets-missing.test.mjs
//
// Unit (example) tests for deleteTargets tolerance of already-missing listed
// files: a manifest path missing on disk does NOT abort the switch; the
// remaining listed files are still deleted.
//
// Requirement 3.3: deleteTargets swallows ENOENT and continues over the
// remaining paths, reporting missing paths in `skipped` and removed paths in
// `deleted` without throwing.
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';

import { deleteTargets } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, pathExists } from './helpers.mjs';

/**
 * Create a file (with parent dirs) under the repo root.
 * @param {string} repoRoot
 * @param {string} rel repo-relative POSIX path
 */
async function createFile(repoRoot, rel) {
  const abs = path.resolve(repoRoot, rel);
  await fs.mkdir(path.dirname(abs), { recursive: true });
  await fs.writeFile(abs, `// ${rel}\n`);
}

test('deleteTargets: interleaved existing/missing paths — deletes existing, skips missing, does not throw', async () => {
  const repoRoot = await makeTempDir('delete-targets-missing-');
  try {
    const existing1 = 'sfera/lib/a.dart';
    const existing2 = 'sfera/lib/sub/b.dart';
    const existing3 = 'warnapp/lib/c.dart';
    const missing1 = 'sfera/lib/gone1.dart';
    const missing2 = 'warnapp/lib/sub/gone2.dart';

    for (const rel of [existing1, existing2, existing3]) {
      await createFile(repoRoot, rel);
    }

    // Interleave existing and non-existent paths.
    const paths = [existing1, missing1, existing2, missing2, existing3];

    let result;
    assert.doesNotThrow(() => {
      result = deleteTargets(repoRoot, paths);
    }, 'deleteTargets must not throw when some listed paths are missing');

    // deleted == the three existing paths; skipped == the two missing paths.
    assert.deepEqual(
      [...result.deleted].sort(),
      [existing1, existing2, existing3].sort(),
      'deleted must equal exactly the existing paths',
    );
    assert.deepEqual(
      [...result.skipped].sort(),
      [missing1, missing2].sort(),
      'skipped must equal exactly the missing paths',
    );

    // The three existing files are gone from disk.
    for (const rel of [existing1, existing2, existing3]) {
      assert.equal(
        await pathExists(path.resolve(repoRoot, rel)),
        false,
        `existing file must be deleted: ${rel}`,
      );
    }
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('deleteTargets: first listed path missing — still proceeds to delete later existing paths', async () => {
  const repoRoot = await makeTempDir('delete-targets-missing-first-');
  try {
    const missingFirst = 'sfera/lib/absent.dart';
    const existing1 = 'sfera/lib/a.dart';
    const existing2 = 'warnapp/lib/b.dart';

    for (const rel of [existing1, existing2]) {
      await createFile(repoRoot, rel);
    }

    // The FIRST entry is missing — the loop must not abort on it.
    const paths = [missingFirst, existing1, existing2];

    let result;
    assert.doesNotThrow(() => {
      result = deleteTargets(repoRoot, paths);
    }, 'a missing first path must not abort deletion of later paths');

    assert.deepEqual(
      [...result.deleted].sort(),
      [existing1, existing2].sort(),
      'deleted must contain the later existing paths',
    );
    assert.deepEqual(result.skipped, [missingFirst], 'skipped must contain the missing first path');

    for (const rel of [existing1, existing2]) {
      assert.equal(
        await pathExists(path.resolve(repoRoot, rel)),
        false,
        `later existing file must be deleted: ${rel}`,
      );
    }
  } finally {
    await removeTempDir(repoRoot);
  }
});

test('deleteTargets: all listed paths missing — deleted empty, skipped is all, no throw', async () => {
  const repoRoot = await makeTempDir('delete-targets-missing-all-');
  try {
    const paths = ['sfera/lib/x.dart', 'warnapp/lib/y.dart', 'app/lib/z.dart'];

    let result;
    assert.doesNotThrow(() => {
      result = deleteTargets(repoRoot, paths);
    }, 'deleteTargets must not throw when every listed path is missing');

    assert.deepEqual(result.deleted, [], 'deleted must be empty when nothing exists');
    assert.deepEqual(
      [...result.skipped].sort(),
      [...paths].sort(),
      'skipped must equal every listed path',
    );
  } finally {
    await removeTempDir(repoRoot);
  }
});
