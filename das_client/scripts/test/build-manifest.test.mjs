// build-manifest.test.mjs
//
// Example/unit tests for buildManifest (schema v2).
//
// Covers: `flavor` is recorded verbatim; `files` is an object-shaped array of
// `{ path, overwrote }` entries, with `path` normalized to forward slashes
// (backslash-separated inputs become POSIX-separated) and `overwrote` carried
// through verbatim; `version` equals the MANIFEST_VERSION integer (2);
// `generatedAt` is a valid ISO-8601 string.
//
// _Requirements: 2.1, 2.2_
//
// Pure Node, zero third-party dependencies. Runs under `node --test`.

import test from 'node:test';
import assert from 'node:assert/strict';

import { buildManifest, MANIFEST_VERSION, FLAVORS } from '../switch-flavor.mjs';

test('flavor is recorded verbatim in the returned manifest', () => {
  for (const flavor of FLAVORS) {
    const result = buildManifest(flavor, []);
    assert.equal(result.flavor, flavor);
  }
});

test('file paths are normalized to forward slashes', () => {
  const result = buildManifest('dev', [
    { path: 'sfera\\lib\\src\\foo.dart', overwrote: true },
    { path: 'core\\lib\\bar.dart', overwrote: false },
  ]);
  assert.equal(result.files[0].path, 'sfera/lib/src/foo.dart');
  assert.equal(result.files[1].path, 'core/lib/bar.dart');
});

test('paths already using forward slashes are left unchanged', () => {
  const result = buildManifest('inte', [
    { path: 'sfera/lib/src/foo.dart', overwrote: false },
  ]);
  assert.equal(result.files[0].path, 'sfera/lib/src/foo.dart');
});

test('overwrote is carried through verbatim for both true and false', () => {
  const result = buildManifest('dev', [
    { path: 'sfera/lib/src/foo.dart', overwrote: true },
    { path: 'core/lib/bar.dart', overwrote: false },
  ]);
  assert.deepEqual(result.files, [
    { path: 'sfera/lib/src/foo.dart', overwrote: true },
    { path: 'core/lib/bar.dart', overwrote: false },
  ]);
});

test('an empty target list yields an empty files array', () => {
  const result = buildManifest('prod', []);
  assert.deepEqual(result.files, []);
});

test('version equals the MANIFEST_VERSION integer (2)', () => {
  const result = buildManifest('dev', []);
  assert.equal(MANIFEST_VERSION, 2);
  assert.equal(Number.isInteger(MANIFEST_VERSION), true);
  assert.equal(result.version, MANIFEST_VERSION);
});

test('generatedAt is a valid ISO-8601 string', () => {
  const result = buildManifest('dev', []);
  assert.equal(typeof result.generatedAt, 'string');
  // Round-tripping through Date must reproduce the exact string, which only
  // holds for a canonical ISO-8601 timestamp.
  assert.equal(new Date(result.generatedAt).toISOString(), result.generatedAt);
});
