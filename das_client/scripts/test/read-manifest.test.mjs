// read-manifest.test.mjs
//
// Example/unit tests for readManifest classification (task 7.5).
//
// readManifest(repoRoot) returns a discriminated union keyed on `state`:
//   - { state: 'MISSING' }                    when .flavor-manifest.json is absent
//   - { state: 'CORRUPT' }                     when JSON.parse fails OR the shape
//                                              is invalid (bad version/flavor/files)
//   - { state: 'VALID', flavor, files }        when parsed + shape-valid
//
// Covers: absent file → MISSING; malformed JSON → CORRUPT; shape-invalid
// content (wrong version, bad flavor, files not an array, files array with a
// non-entry element, non-object top-level JSON) → CORRUPT; a surviving v1
// manifest (version 1, string[] files) → CORRUPT (no v1→v2 migration);
// well-formed schema-v2 manifest → VALID exposing `files` as entry objects.
//
// _Requirements: 2.3, 4.1, 4.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`. Each test
// uses a fresh temp dir and tears it down afterwards.

import test from 'node:test';
import assert from 'node:assert/strict';

import { readManifest, MANIFEST_VERSION, FLAVORS } from '../switch-flavor.mjs';
import { makeTempDir, removeTempDir, buildRepo } from './helpers.mjs';

/**
 * Run `fn` with a temp repo built from `spec`, cleaning up afterwards.
 * @param {import('./helpers.mjs').RepoSpec} spec
 * @param {(repoRoot: string) => Promise<void>} fn
 */
async function withRepo(spec, fn) {
  const dir = await makeTempDir();
  try {
    await buildRepo(dir, spec);
    await fn(dir);
  } finally {
    await removeTempDir(dir);
  }
}

test('absent manifest file → MISSING', async () => {
  // buildRepo with no manifest/manifestRaw leaves .flavor-manifest.json absent.
  await withRepo({}, async (repoRoot) => {
    assert.deepEqual(readManifest(repoRoot), { state: 'MISSING' });
  });
});

test('malformed JSON → CORRUPT', async () => {
  await withRepo({ manifestRaw: '{ not json' }, async (repoRoot) => {
    assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
  });
});

test('shape-invalid: wrong version → CORRUPT', async () => {
  await withRepo(
    {
      manifest: {
        version: MANIFEST_VERSION + 1,
        flavor: 'dev',
        files: [{ path: 'app/lib/foo.dart', overwrote: false }],
      },
    },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('v1-shaped manifest (version 1, string[] files) → CORRUPT (no v1→v2 migration)', async () => {
  // A surviving v1 manifest must be rejected: there is deliberately no v1→v2
  // migration, so routing it to the safe copy-only path (CORRUPT) guarantees no
  // stale v1 path is ever deleted blindly (Req 4.2; design "Why no migration
  // from v1").
  await withRepo(
    { manifest: { version: 1, flavor: 'dev', files: ['app/lib/x.dart'] } },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('shape-invalid: bad flavor → CORRUPT', async () => {
  await withRepo(
    { manifest: { version: MANIFEST_VERSION, flavor: 'staging', files: [] } },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('shape-invalid: files not an array → CORRUPT', async () => {
  await withRepo(
    { manifest: { version: MANIFEST_VERSION, flavor: 'dev', files: 'app/lib/foo.dart' } },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('shape-invalid: files array containing a non-entry element → CORRUPT', async () => {
  await withRepo(
    {
      manifest: {
        version: MANIFEST_VERSION,
        flavor: 'dev',
        files: [{ path: 'app/lib/foo.dart', overwrote: false }, 42],
      },
    },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('shape-invalid: files entry missing overwrote flag → CORRUPT', async () => {
  await withRepo(
    {
      manifest: {
        version: MANIFEST_VERSION,
        flavor: 'dev',
        files: [{ path: 'app/lib/foo.dart' }],
      },
    },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
    },
  );
});

test('non-object top-level JSON (array) → CORRUPT', async () => {
  await withRepo({ manifestRaw: '[]' }, async (repoRoot) => {
    assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
  });
});

test('non-object top-level JSON (number) → CORRUPT', async () => {
  await withRepo({ manifestRaw: '42' }, async (repoRoot) => {
    assert.deepEqual(readManifest(repoRoot), { state: 'CORRUPT' });
  });
});

test('well-formed manifest → VALID with flavor and files (entry objects) exposed', async () => {
  const files = [
    { path: 'app/lib/foo.dart', overwrote: false },
    { path: 'sfera/lib/src/bar.dart', overwrote: true },
  ];
  await withRepo(
    { manifest: { version: MANIFEST_VERSION, flavor: 'inte', files, generatedAt: '2024-01-01T00:00:00.000Z' } },
    async (repoRoot) => {
      assert.deepEqual(readManifest(repoRoot), {
        state: 'VALID',
        flavor: 'inte',
        files,
      });
    },
  );
});

test('every valid flavor with an empty files list → VALID', async () => {
  for (const flavor of FLAVORS) {
    await withRepo(
      { manifest: { version: MANIFEST_VERSION, flavor, files: [] } },
      async (repoRoot) => {
        assert.deepEqual(readManifest(repoRoot), {
          state: 'VALID',
          flavor,
          files: [],
        });
      },
    );
  }
});
