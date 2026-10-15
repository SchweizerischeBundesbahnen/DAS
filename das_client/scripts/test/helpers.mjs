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
 * @property {Record<string,string>} [test]    files under test/, keyed by relative POSIX path → content
 *           (optional; mirrors `lib`. Creates sfera/test/<rel> entries so fixtures
 *           can pre-seed base files under the `test/` Flavor_Source_Root.)
 * @property {Record<string,Record<string,string>>} [flavors]
 *           flavor folders: flavorName → { relativePosixPath → content }
 *           e.g. { dev: { "src/foo.dart": "..." } } creates sfera/.dev/src/foo.dart
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
 *   - <dir>/<component>/.<flavor>/<...>        (per flavors spec)
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

    // Optional base files under the `test/` Flavor_Source_Root. Mirrors `lib`;
    // omitted components get no `test/` dir (backward-compatible default).
    for (const [rel, content] of Object.entries(component.test ?? {})) {
      await writeFile(path.join(compDir, 'test', rel), content);
    }

    for (const [flavor, files] of Object.entries(component.flavors ?? {})) {
      for (const [rel, content] of Object.entries(files)) {
        await writeFile(path.join(compDir, `.${flavor}`, rel), content);
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
 * Recognized Flavor_Source_Roots inside a flavor folder, mirroring
 * `SOURCE_ROOTS` in `switch-flavor.mjs`. A Flavor_Folder is a partial mirror of
 * the Workspace_Component root, so only these top-level dirs (`.<flavor>/lib/`
 * and `.<flavor>/test/`) are copied/mapped on a switch; anything else is ignored
 * (Req 1.6).
 * @type {ReadonlyArray<'lib'|'test'>}
 */
export const SOURCE_ROOTS = ['lib', 'test'];

/**
 * @typedef {Object} SourceRootTree
 * @property {Record<string,string>} tree
 *   The flavor files to seed, keyed by the flavor-folder-relative POSIX path
 *   (e.g. `lib/src/foo.dart`, `test/foo_test.dart`, or a stray `bin/x.dart`).
 *   Pass this directly as a component's `flavors[flavor]` value — `buildRepo`
 *   writes each entry to `<component>/.<flavor>/<rel>` verbatim, so the keys
 *   already encode the on-disk layout.
 * @property {Record<string,string>} mapped
 *   Only the entries that fall under a recognized {@link SOURCE_ROOTS} root,
 *   keyed by the flavor-folder-relative path (`<root>/<rest>`) → content. These
 *   are the files a switch SHALL copy; the matching repo-relative target is
 *   `<component>/<root>/<rest>`.
 * @property {Record<string,string>} strays
 *   The entries that fall OUTSIDE any recognized source root (files directly
 *   under `.<flavor>/` or under an unrecognized top-level dir such as `bin/`).
 *   A switch SHALL ignore these (Req 1.6); kept so callers can assert they are
 *   never copied.
 */

/**
 * Build a random flavor-folder tree spread across BOTH recognized source roots
 * (`.<flavor>/lib/...` and `.<flavor>/test/...`), optionally sprinkled with
 * stray entries OUTSIDE any source root (directly under `.<flavor>/` or under an
 * unrecognized top-level dir like `.<flavor>/bin/...`) to exercise the Req 1.6
 * ignore rule.
 *
 * Separates the files into `mapped` (under `lib/`/`test/` — a switch copies
 * these to `<component>/<root>/<rest>`) and `strays` (ignored). The combined
 * `tree` is what callers hand to a component's `flavors[flavor]` in
 * {@link buildRepo}; the split sets let the caller assert copy fidelity for
 * `mapped` and non-copy for `strays` without re-deriving the layout.
 *
 * The randomness is injected via the `random` callbacks so a property test can
 * reuse its own generator conventions (iteration count, name/content shapes)
 * rather than this helper owning them.
 *
 * @param {Object} random
 * @param {() => string} random.name       produce a random path segment
 * @param {() => string} random.content    produce random file content
 * @param {(maxExclusive: number) => number} random.int  random int in [0, max)
 * @param {Object} [opts]
 * @param {boolean} [opts.allowStrays=true] when false, never emit stray entries
 * @returns {SourceRootTree}
 */
export function buildSourceRootTree(random, opts = {}) {
  const { name, content, int } = random;
  const { allowStrays = true } = opts;

  const mapped = {};
  const strays = {};

  // A shared pool of nested dir prefixes (incl. the empty prefix) so files under
  // the same root share intermediate dirs, exercising "create missing dirs once".
  const makeDirPool = () => {
    const pool = [''];
    const extra = int(3);
    for (let i = 0; i < extra; i++) {
      const depth = 1 + int(3);
      const segs = [];
      for (let d = 0; d < depth; d++) segs.push(name());
      pool.push(segs.join('/'));
    }
    return pool;
  };

  // Seed each recognized source root with >= 1 file so BOTH roots are exercised.
  for (const root of SOURCE_ROOTS) {
    const dirPool = makeDirPool();
    const fileCount = 1 + int(4); // 1..4 files per root
    let attempts = 0;
    let placed = 0;
    while (placed < fileCount && attempts < fileCount * 10) {
      attempts++;
      const dir = dirPool[int(dirPool.length)];
      const rel = `${root}/${dir === '' ? '' : `${dir}/`}${name()}.dart`;
      if (Object.prototype.hasOwnProperty.call(mapped, rel)) continue;
      mapped[rel] = content();
      placed++;
    }
  }

  // Occasionally sprinkle stray entries OUTSIDE any source root (Req 1.6):
  //   - directly under `.<flavor>/` (no root segment)
  //   - under an unrecognized top-level dir (e.g. `bin/`)
  if (allowStrays) {
    const strayCount = int(3); // 0..2 strays
    const unrecognizedDirs = ['bin', 'example', 'tool', 'doc'];
    for (let i = 0; i < strayCount; i++) {
      const underRoot = int(2) === 0;
      const rel = underRoot
        ? `${unrecognizedDirs[int(unrecognizedDirs.length)]}/${name()}.dart`
        : `${name()}.dart`; // directly under `.<flavor>/`
      if (
        Object.prototype.hasOwnProperty.call(mapped, rel) ||
        Object.prototype.hasOwnProperty.call(strays, rel)
      ) {
        continue;
      }
      strays[rel] = content();
    }
  }

  return { tree: { ...mapped, ...strays }, mapped, strays };
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
