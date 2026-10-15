// helpers.mjs
//
// Test harness helpers for the flavor-switch script test suite.
// Pure Node, zero third-party dependencies. Used by node:test suites.
//
// Provides:
//   - temp-dir setup/teardown (fs.mkdtemp(os.tmpdir()) + fs.rm recursive/force)
//   - a miniature-repo fixture builder (root pubspec.yaml, component dirs with
//     lib/ and optional flavor folders, app/pubspec.yaml)

import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';

/**
 * Create a fresh temporary directory for a test fixture.
 * @param {string} [prefix] name prefix for the temp dir
 * @returns {Promise<string>} absolute path of the created directory
 */
export async function makeTempDir(prefix = 'flavor-switch-') {
  return fs.mkdtemp(path.join(os.tmpdir(), prefix));
}

/**
 * Recursively remove a temporary directory. Safe to call on a non-existent path.
 * @param {string} dir absolute path previously returned by makeTempDir
 * @returns {Promise<void>}
 */
export async function removeTempDir(dir) {
  if (!dir) return;
  await fs.rm(dir, { recursive: true, force: true });
}

/**
 * Run `fn` with a fresh temp dir, cleaning up afterwards even on failure.
 * @template T
 * @param {(dir: string) => Promise<T>} fn
 * @param {string} [prefix]
 * @returns {Promise<T>}
 */
export async function withTempDir(fn, prefix) {
  const dir = await makeTempDir(prefix);
  try {
    return await fn(dir);
  } finally {
    await removeTempDir(dir);
  }
}

/**
 * @typedef {Object} ComponentSpec
 * @property {string} name                     component directory name (e.g. "sfera")
 * @property {Record<string,string>} [lib]     files under lib/, keyed by relative POSIX path → content
 * @property {Record<string,Record<string,string>>} [flavors]
 *           flavor folders: flavorName → { relativePosixPath → content }
 *           e.g. { dev: { "src/foo.dart": "..." } } creates sfera/dev/src/foo.dart
 * @property {boolean} [noPubspec]             when true, skip writing the component pubspec.yaml
 * @property {boolean} [noLib]                 when true, skip creating the lib/ folder
 */

/**
 * @typedef {Object} RepoSpec
 * @property {ComponentSpec[]} [components]     workspace components to create
 * @property {string} [rootPubspec]            override the root pubspec.yaml content
 * @property {string} [appPubspec]             override app/pubspec.yaml content
 * @property {object} [manifest]               manifest object to write to .flavor-manifest.json
 * @property {string} [manifestRaw]            raw manifest text (takes precedence over `manifest`)
 */

const DEFAULT_ROOT_PUBSPEC = `name: _
publish_to: none
environment:
  sdk: ^3.0.0
workspace:
  - "*"
`;

const DEFAULT_APP_PUBSPEC = `name: das_client
publish_to: none

environment:
  sdk: ^3.0.0

resolution: workspace

dependencies:
  flutter:
    sdk: flutter

  # workspace packages
  sfera: any
  warnapp: any

  # https://pub.dev/packages/collection
  collection: ^1.18.0
`;

/**
 * Write a file, creating parent directories as needed.
 * @param {string} filePath
 * @param {string} content
 */
async function writeFile(filePath, content) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, content);
}

/**
 * Build a miniature workspace repo inside `dir` from a declarative spec.
 *
 * Creates:
 *   - <dir>/pubspec.yaml                      (root workspace pubspec)
 *   - <dir>/app/pubspec.yaml                  (app component pubspec)
 *   - <dir>/<component>/pubspec.yaml          (unless noPubspec)
 *   - <dir>/<component>/lib/<...>             (unless noLib)
 *   - <dir>/<component>/<flavor>/<...>        (per flavors spec)
 *   - <dir>/.flavor-manifest.json             (when manifest/manifestRaw given)
 *
 * @param {string} dir   absolute path of an existing (temp) directory
 * @param {RepoSpec} [spec]
 * @returns {Promise<string>} the repo root dir (same as `dir`), for convenience
 */
export async function buildRepo(dir, spec = {}) {
  const {
    components = [],
    rootPubspec = DEFAULT_ROOT_PUBSPEC,
    appPubspec = DEFAULT_APP_PUBSPEC,
    manifest,
    manifestRaw,
  } = spec;

  // Root workspace pubspec.
  await writeFile(path.join(dir, 'pubspec.yaml'), rootPubspec);

  // app component pubspec (always present as a workspace member).
  await writeFile(path.join(dir, 'app', 'pubspec.yaml'), appPubspec);
  await fs.mkdir(path.join(dir, 'app', 'lib'), { recursive: true });

  // Components.
  for (const component of components) {
    const compDir = path.join(dir, component.name);

    if (!component.noPubspec) {
      await writeFile(
        path.join(compDir, 'pubspec.yaml'),
        `name: ${component.name}\npublish_to: none\nenvironment:\n  sdk: ^3.0.0\n`,
      );
    }

    if (!component.noLib) {
      await fs.mkdir(path.join(compDir, 'lib'), { recursive: true });
    }

    for (const [rel, content] of Object.entries(component.lib ?? {})) {
      await writeFile(path.join(compDir, 'lib', rel), content);
    }

    for (const [flavor, files] of Object.entries(component.flavors ?? {})) {
      for (const [rel, content] of Object.entries(files)) {
        await writeFile(path.join(compDir, flavor, rel), content);
      }
    }
  }

  // Optional manifest.
  if (manifestRaw !== undefined) {
    await writeFile(path.join(dir, '.flavor-manifest.json'), manifestRaw);
  } else if (manifest !== undefined) {
    await writeFile(
      path.join(dir, '.flavor-manifest.json'),
      JSON.stringify(manifest, null, 2),
    );
  }

  return dir;
}

/**
 * Convenience: create a temp dir AND build a repo in it in one step.
 * Caller is responsible for teardown via removeTempDir.
 * @param {RepoSpec} [spec]
 * @returns {Promise<string>} the repo root dir
 */
export async function makeRepo(spec) {
  const dir = await makeTempDir();
  await buildRepo(dir, spec);
  return dir;
}

/**
 * Read a file as UTF-8 text, or return undefined if it does not exist.
 * @param {string} filePath
 * @returns {Promise<string|undefined>}
 */
export async function readFileOrUndefined(filePath) {
  try {
    return await fs.readFile(filePath, 'utf8');
  } catch (err) {
    if (err && err.code === 'ENOENT') return undefined;
    throw err;
  }
}

/**
 * Check whether a path exists.
 * @param {string} filePath
 * @returns {Promise<boolean>}
 */
export async function pathExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}
