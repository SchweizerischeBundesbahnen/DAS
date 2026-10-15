// switch-flavor.mjs
//
// Flavor-Based Code-Switching System for the DAS Client Dart workspace.
//
// Standalone Node/ESM script with ZERO third-party dependencies. It emulates
// Android-style flavor source sets: on `node scripts/switch-flavor.mjs <flavor>`
// it copies every workspace component's `<flavor>/` folder into that component's
// `lib/`, records the copied files in `.flavor-manifest.json`, and (optionally)
// removes a workspace package dependency from `app/pubspec.yaml`.
//
// Design note: every core function accepts `repoRoot` as an injected parameter
// (dependency injection) so the test suite can run them against temp-dir
// fixtures. The real `repoRoot` is derived from `import.meta.url` ONLY in the
// CLI entry wiring (added in a later task), never inside a core function.
//
// See .kiro/specs/flavor-code-switching/{requirements,design,tasks}.md.

import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import { parseArgs } from 'node:util';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// ---------------------------------------------------------------------------
// Shared constants
// ---------------------------------------------------------------------------

/** Valid flavors, in canonical order. */
export const FLAVORS = ['dev', 'inte', 'prod'];

/** Manifest file name, relative to the repo root. */
export const MANIFEST_FILENAME = '.flavor-manifest.json';

/** Current manifest schema version. */
export const MANIFEST_VERSION = 2;

/**
 * Base-backup directory name, relative to the repo root. Holds a mirror of every
 * `lib/` Base_File that a switch overwrote, so `lib/` can be restored to its
 * pre-switch base state. Gitignored (local staging artifact, not reviewable
 * state). See design "Base Backup Model → Location and structure".
 */
export const BASE_BACKUP_DIRNAME = '.flavor-base-backup';

/**
 * Resolve the absolute path of the manifest file for a given repo root.
 * @param {string} repoRoot
 * @returns {string}
 */
export function manifestPath(repoRoot) {
  return path.join(repoRoot, MANIFEST_FILENAME);
}

/**
 * Resolve the absolute path of the base-backup directory for a given repo root.
 * Mirrors {@link manifestPath}.
 * @param {string} repoRoot
 * @returns {string}
 */
export function baseBackupDir(repoRoot) {
  return path.join(repoRoot, BASE_BACKUP_DIRNAME);
}

/**
 * Build the CLI usage/help text (pure, no I/O).
 *
 * Returns the complete `--help`/`-h` output as a single string: a one-line
 * summary of what the tool does, the invocation synopsis, and a description of
 * each argument. The valid flavors are rendered from the {@link FLAVORS}
 * constant so the help text stays in sync with the actual accepted values
 * (Req 6.1, 6.2).
 *
 * Kept pure and exported so it can be unit-tested directly and so `main()` can
 * print it with a single `console.log(usageText())` when `--help`/`-h` is set.
 *
 * @returns {string} the full usage text (no trailing newline)
 */
export function usageText() {
  return [
    "Switch the DAS client workspace to a build flavor by copying each component's",
    '<flavor>/ folder into its lib/, tracking the copied files in .flavor-manifest.json.',
    '',
    'Usage:',
    '  node scripts/switch-flavor.mjs <flavor> [--remove-dep=<package>]',
    '  node scripts/switch-flavor.mjs --restore-base',
    '  node scripts/switch-flavor.mjs --save-to-flavor=<flavor> <file>',
    '  node scripts/switch-flavor.mjs --save-to-flavor=<flavor> --all',
    '',
    'Arguments:',
    `  <flavor>              The flavor to switch to. One of: ${FLAVORS.join(', ')}.`,
    '                        Selects the <flavor>/ source folder copied into each',
    "                        component's lib/.",
    '',
    'Options:',
    '  --remove-dep=<package>  Remove the given workspace package from app/pubspec.yaml',
    '                          and refresh workspace resolution afterwards.',
    '  --restore-base          Restore lib/ to its base state (revert the last switch): copy',
    '                          backed-up base files back and remove newly added flavor files.',
    `  --save-to-flavor=<flavor> <file>`,
    `                          Copy an existing lib/ file into <flavor>/ (one of: ${FLAVORS.join(', ')});`,
    '                          the file stays in lib/. <file> is a repo-relative path like',
    '                          sfera/lib/src/foo.dart.',
    '  --all                   With --save-to-flavor, save every Git-changed lib/ file (working tree vs',
    '                          HEAD, incl. untracked) into <flavor>/ instead of a single <file>; files',
    '                          deleted in lib/ are removed from <flavor>/ if present.',
    '  --dry-run               Preview the switch: print the files that would be copied,',
    '                          deleted, and the pubspec line that would be removed,',
    '                          without touching the filesystem.',
    '  --help, -h              Show this help and exit.',
  ].join('\n');
}

// ---------------------------------------------------------------------------
// Core functions — stubs to be implemented in later tasks.
// Each is a named export so tests can import it directly.
// ---------------------------------------------------------------------------

/**
 * @typedef {Object} ParseOk
 * @property {true} ok
 * @property {string|undefined} flavor  Switch mode: the positional flavor (one of
 *   {@link FLAVORS}). Undefined in restore-base and save-to-flavor modes.
 * @property {string|undefined} removeDep  Workspace package to remove, or undefined.
 * @property {boolean} restoreBase  Whether `--restore-base` was requested (restore-base mode).
 * @property {{flavor: string, file: (string|undefined), all: boolean}|undefined} saveToFlavor  Set
 *   when `--save-to-flavor` was requested: `flavor` is the option value, `all` is the boolean
 *   `--all` modifier, and `file` is the source positional when `all` is `false` (single-file form)
 *   or `undefined` when `all` is `true` (the positional is not required and is ignored). Undefined
 *   in all other modes.
 * @property {boolean} help       Whether `--help`/`-h` was requested.
 * @property {boolean} dryRun     Whether `--dry-run` was requested (preview only, no mutation).
 *
 * @typedef {Object} ParseErr
 * @property {false} ok
 * @property {string} error       Human-readable validation message for stderr.
 *
 * @typedef {ParseOk|ParseErr} ParseResult
 */

/**
 * Parse and validate CLI arguments (pure, no I/O).
 *
 * Returns a discriminated result object rather than throwing so that `main()`
 * (task 10.2) can consume it with a single `if (!result.ok)` branch, print
 * `result.error` to stderr, and exit non-zero before any mutation — satisfying
 * Req 6.1/6.2/6.4 (no changes on invalid input). On success the caller reads
 * `result.flavor`, `result.removeDep`, and `result.help` directly.
 *
 * @param {string[]} argv  Full argv (e.g. `process.argv`); the first two entries
 *   (node binary, script path) are skipped, matching `parseArgs` conventions.
 * @returns {ParseResult}
 */
export function parseCliArgs(argv) {
  let values;
  let positionals;
  try {
    ({ values, positionals } = parseArgs({
      args: argv.slice(2),
      allowPositionals: true,
      options: {
        'remove-dep': { type: 'string' },
        'restore-base': { type: 'boolean' },
        'save-to-flavor': { type: 'string' },
        all: { type: 'boolean' },
        help: { type: 'boolean', short: 'h' },
        'dry-run': { type: 'boolean' },
      },
    }));
  } catch (err) {
    // parseArgs throws on unknown options / malformed flags. Surface it as a
    // validation error instead of letting it escape as an exception.
    return { ok: false, error: err instanceof Error ? err.message : String(err) };
  }

  const help = values.help === true;
  const dryRun = values['dry-run'] === true;
  const removeDep = values['remove-dep'];
  const restoreBase = values['restore-base'] === true;
  const saveToFlavorFlavor = values['save-to-flavor']; // flavor name or undefined
  const all = values['all'] === true;
  const flavor = positionals[0];

  // --help short-circuits validation: usage can be shown without a flavor. Carry
  // the new mode fields through so the success shape stays consistent.
  if (help) {
    return { ok: true, flavor, removeDep, restoreBase, saveToFlavor: undefined, help: true, dryRun };
  }

  // Restore-base and save-to-flavor are mutually exclusive standalone modes
  // (design "Mode dispatch and precedence" → Conflict handling). Reject the
  // ambiguous combination before any mode-specific validation.
  if (restoreBase && saveToFlavorFlavor !== undefined) {
    return { ok: false, error: '--restore-base and --save-to-flavor cannot be combined' };
  }

  // The `--all` modifier is only meaningful alongside `--save-to-flavor`
  // (design "Mode dispatch and precedence" → Conflict handling). Reject the two
  // invalid `--all` combinations before any mode-specific validation.
  if (all && restoreBase) {
    return { ok: false, error: '--all cannot be combined with --restore-base' };
  }
  if (all && saveToFlavorFlavor === undefined) {
    return { ok: false, error: '--all requires --save-to-flavor' };
  }

  // Restore-base mode: no flavor positional is required and the flavor is not
  // validated (any positional is ignored).
  if (restoreBase) {
    return {
      ok: true,
      flavor: undefined,
      removeDep,
      restoreBase: true,
      saveToFlavor: undefined,
      help: false,
      dryRun,
    };
  }

  // Save-to-flavor mode: validate the option value (flavor) and require the
  // source file positional before any I/O (Req 12.5).
  if (saveToFlavorFlavor !== undefined) {
    if (!FLAVORS.includes(saveToFlavorFlavor)) {
      return {
        ok: false,
        error: `Not a valid flavor: '${saveToFlavorFlavor}' (expected ${FLAVORS.join('|')})`,
      };
    }
    // Single-file form requires the source positional; the `--all` form takes no
    // positional (any positional is ignored), so the requirement does not apply.
    const file = all ? undefined : positionals[0];
    if (!all && file === undefined) {
      return { ok: false, error: 'A source file is required for --save-to-flavor' };
    }
    return {
      ok: true,
      flavor: undefined,
      removeDep,
      restoreBase: false,
      saveToFlavor: { flavor: saveToFlavorFlavor, file, all },
      help: false,
      dryRun,
    };
  }

  // Switch mode: the flavor positional is required and must be valid.
  if (flavor === undefined) {
    return { ok: false, error: 'A flavor parameter is required' };
  }

  if (!FLAVORS.includes(flavor)) {
    return { ok: false, error: `Not a valid flavor: '${flavor}' (expected ${FLAVORS.join('|')})` };
  }

  return { ok: true, flavor, removeDep, restoreBase: false, saveToFlavor: undefined, help: false, dryRun };
}

/**
 * Directory names that are never workspace components. Hidden directories
 * (leading `.`) are also skipped; this set covers the non-hidden tooling dirs.
 */
const NON_PACKAGE_DIRS = new Set(['.kiro', '.fvm', '.dart_tool', 'build', 'scripts']);

/**
 * Discover workspace component directories under `repoRoot`.
 *
 * Per the design "Component Discovery": the workspace is declared as a glob
 * (`workspace: - "*"`), so discovery is a directory scan, not a parse of an
 * explicit list. A directory qualifies as a Workspace_Component when it is an
 * immediate child of `repoRoot` that contains BOTH a `pubspec.yaml` file and a
 * `lib/` directory. Hidden directories (leading `.`) and known tooling dirs
 * (`.kiro`, `.fvm`, `.dart_tool`, `build`, `scripts`) are skipped defensively.
 *
 * Contract: returns an array of `{ name, dir }` where `name` is the directory
 * basename and `dir` is the absolute path to the component directory. This shape
 * lets `planCopy` consume `dir` directly and lets `main` report by `name`. The
 * array is sorted by `name` for deterministic ordering. Uses synchronous fs
 * (consistent with the rest of this module).
 *
 * @param {string} repoRoot absolute path to the repo root
 * @returns {Array<{name: string, dir: string}>}
 */
export function discoverComponents(repoRoot) {
  let entries;
  try {
    entries = fs.readdirSync(repoRoot, { withFileTypes: true });
  } catch {
    return [];
  }

  const components = [];
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const name = entry.name;
    // Skip hidden dirs and known non-package/tooling dirs.
    if (name.startsWith('.') || NON_PACKAGE_DIRS.has(name)) continue;

    const dir = path.join(repoRoot, name);
    const hasPubspec = fs.existsSync(path.join(dir, 'pubspec.yaml'));
    const libPath = path.join(dir, 'lib');
    const hasLib = fs.existsSync(libPath) && fs.statSync(libPath).isDirectory();

    if (hasPubspec && hasLib) {
      components.push({ name, dir });
    }
  }

  components.sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
  return components;
}

/**
 * Enumerate a component's flavor-folder files and map them to `lib/` targets.
 *
 * Per the design "Copy semantics": when `<componentDir>/<flavor>/` exists and is
 * a directory, every file beneath it (recursively) at relative path `<relpath>`
 * maps to the target `<componentDir>/lib/<relpath>`, preserving the nested
 * structure. A component without a matching flavor folder contributes nothing
 * (empty array).
 *
 * Contract: returns an array of copy entries
 *   `{ source: string, target: string }`
 * where `source` is the ABSOLUTE path to the flavor-folder file and `target` is
 * the REPO-ROOT-RELATIVE POSIX path (forward slashes) of the destination under
 * `lib/`. `repoRoot` is accepted as a parameter so the target can be made
 * repo-relative here — this matches what `buildManifest`/the manifest expect
 * (`files` are repo-root-relative POSIX paths), so `main` can feed the copied
 * targets straight into `copyFiles` and `buildManifest` without re-relativizing.
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * @param {string} componentDir absolute path to the component directory
 * @param {string} flavor one of {@link FLAVORS}
 * @param {string} repoRoot absolute path to the repo root (for repo-relative targets)
 * @returns {Array<{source: string, target: string}>}
 */
export function planCopy(componentDir, flavor, repoRoot) {
  const flavorDir = path.join(componentDir, flavor);

  let stat;
  try {
    stat = fs.statSync(flavorDir);
  } catch {
    // Flavor folder does not exist → component contributes nothing.
    return [];
  }
  if (!stat.isDirectory()) return [];

  const libDir = path.join(componentDir, 'lib');
  const entries = [];

  // Recursively walk the flavor folder, mapping each file to its lib/ target.
  const walk = (currentDir) => {
    const dirents = fs.readdirSync(currentDir, { withFileTypes: true });
    for (const dirent of dirents) {
      const abs = path.join(currentDir, dirent.name);
      if (dirent.isDirectory()) {
        walk(abs);
      } else if (dirent.isFile()) {
        const relFromFlavor = path.relative(flavorDir, abs);
        const targetAbs = path.join(libDir, relFromFlavor);
        const targetRel = path.relative(repoRoot, targetAbs).split(path.sep).join('/');
        entries.push({ source: abs, target: targetRel });
      }
    }
  };
  walk(flavorDir);

  return entries;
}

/**
 * Map a `<component>/lib/<rest>` source path to its flavor-folder destination
 * `<component>/<flavor>/<rest>` (pure, no filesystem access).
 *
 * Per the design "Save-to-Flavor Operation" (step 4) and the `deriveFlavorDest`
 * row in the Components-and-Interfaces module table: this derives the authoring
 * destination for `--save-to-flavor` by replacing the FIRST `lib/` segment that
 * directly follows the top-level component segment with `<flavor>/`, preserving
 * the remaining relative structure. The flavor is NOT validated here — the
 * caller (`saveToFlavor`, task 17.2) checks `FLAVORS` membership first.
 *
 * Shape contract (Req 12.2, 12.7): `file` must be a repo-relative POSIX path of
 * the form `<component>/lib/<rest>` where `<component>` is a single, non-empty
 * path segment and `<rest>` is non-empty. Backslashes are normalized to forward
 * slashes defensively before matching. A path with no component segment before
 * `lib/` (e.g. `lib/foo.dart`) or with no `/lib/` segment at all is NOT a lib
 * path.
 *
 * Return shape (discriminated union consumed by `saveToFlavor` in task 17.2):
 *   - { ok: true,  dest }                         — `dest` is the repo-relative
 *       POSIX destination `<component>/<flavor>/<rest>`
 *   - { ok: false, reason: 'not_a_lib_path' }     — not a `<component>/lib/<rest>`
 *       path
 *
 * Examples:
 *   deriveFlavorDest('sfera/lib/src/foo.dart', 'dev')
 *     → { ok: true, dest: 'sfera/dev/src/foo.dart' }
 *   deriveFlavorDest('sfera/foo.dart', 'dev')  → { ok: false, reason: 'not_a_lib_path' }
 *   deriveFlavorDest('lib/foo.dart', 'dev')    → { ok: false, reason: 'not_a_lib_path' }
 *
 * @param {string} file repo-relative POSIX source path (`<component>/lib/<rest>`)
 * @param {string} flavor the flavor name (unvalidated here; see {@link FLAVORS})
 * @returns {{ok: true, dest: string} | {ok: false, reason: 'not_a_lib_path'}}
 */
export function deriveFlavorDest(file, flavor) {
  // Normalize backslashes defensively so Windows-style inputs still match.
  const normalized = String(file).replace(/\\/g, '/');

  // Match `<component>/lib/<rest>` where <component> is a single, non-empty
  // segment (no slashes) and <rest> is non-empty. Only the first `lib/` segment
  // directly following the top-level component is replaced.
  const m = /^([^/]+)\/lib\/(.+)$/.exec(normalized);
  if (!m) {
    return { ok: false, reason: 'not_a_lib_path' };
  }

  const component = m[1];
  const rest = m[2];
  return { ok: true, dest: `${component}/${flavor}/${rest}` };
}

/**
 * Load the manifest from `<repoRoot>/.flavor-manifest.json` and classify it into
 * one of three states that `main()` (task 10.2) branches on (Req 2.3, 4.1, 4.2).
 *
 * Classification:
 *   - MISSING — the manifest file does not exist (`fs.readFileSync` throws
 *     `ENOENT`) → first-run path, deletion skipped (Req 4.1).
 *   - CORRUPT — the file exists but either (a) fails `JSON.parse`, OR (b) fails
 *     schema-v2 shape validation: the top-level value is not a plain object,
 *     `version` is not the expected integer ({@link MANIFEST_VERSION}, i.e. `2`),
 *     `flavor` is not one of {@link FLAVORS}, or `files` is not an array where
 *     EVERY element is an entry object `{ path: string, overwrote: boolean }`
 *     → copy-only path, deletion skipped (Req 4.2). Because
 *     {@link MANIFEST_VERSION} is `2`, any surviving v1 manifest (`version: 1`,
 *     `files: string[]`) is classified CORRUPT: there is deliberately no v1→v2
 *     migration — an old manifest is transient and fully regenerated by a single
 *     re-switch, and routing it to copy-only guarantees no stale v1 path is ever
 *     deleted blindly (design "#### Why no migration from v1").
 *   - VALID — parses and passes schema-v2 shape validation; exposes `flavor` and
 *     the `files` array of ENTRY OBJECTS (`{ path, overwrote }`, NOT bare path
 *     strings) so the `path` values can drive deletion and the `overwrote` flags
 *     can drive restore-base (Req 2.3).
 *
 * Any read error other than `ENOENT` (e.g. the file exists but cannot be read)
 * is treated as CORRUPT rather than crashing the switch — the safe fallback is
 * copy-only. Uses synchronous fs (consistent with the rest of this module) via
 * the existing {@link manifestPath} helper.
 *
 * Return shape (discriminated union keyed on `state`, exactly one of
 * `'MISSING' | 'CORRUPT' | 'VALID'`):
 *   - { state: 'MISSING' }
 *   - { state: 'CORRUPT' }
 *   - { state: 'VALID', flavor, files }  // files: Array<{ path, overwrote }>
 *
 * @param {string} repoRoot absolute path to the repo root
 * @returns {{state: 'MISSING'} | {state: 'CORRUPT'} | {state: 'VALID', flavor: string, files: Array<{path: string, overwrote: boolean}>}}
 */
export function readManifest(repoRoot) {
  let raw;
  try {
    raw = fs.readFileSync(manifestPath(repoRoot), 'utf8');
  } catch (err) {
    // Absent file → first-run path. Any other read failure falls back to the
    // safe copy-only path (CORRUPT) rather than crashing the switch.
    if (err && err.code === 'ENOENT') {
      return { state: 'MISSING' };
    }
    return { state: 'CORRUPT' };
  }

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { state: 'CORRUPT' };
  }

  // Schema-v2 shape validation (Req 4.2): the top-level value must be a plain
  // object with the expected version, a valid flavor, and a `files` array whose
  // every element is a `{ path: string, overwrote: boolean }` entry object. Any
  // v1 manifest (`version: 1`, `files: string[]`) fails the version check below
  // and is classified CORRUPT (design "#### Why no migration from v1").
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    return { state: 'CORRUPT' };
  }
  if (parsed.version !== MANIFEST_VERSION) {
    return { state: 'CORRUPT' };
  }
  if (!FLAVORS.includes(parsed.flavor)) {
    return { state: 'CORRUPT' };
  }
  if (
    !Array.isArray(parsed.files) ||
    !parsed.files.every(
      (f) =>
        typeof f === 'object' &&
        f !== null &&
        typeof f.path === 'string' &&
        typeof f.overwrote === 'boolean',
    )
  ) {
    return { state: 'CORRUPT' };
  }

  return { state: 'VALID', flavor: parsed.flavor, files: parsed.files };
}

/**
 * Delete only the listed repo-relative paths; tolerant of already-missing files
 * (Req 3.1, 3.2, 3.3).
 *
 * `paths` is the manifest `files` list — repo-root-relative POSIX paths. For
 * each entry the absolute path is resolved via `path.resolve(repoRoot, p)` and
 * removed with `fs.unlinkSync`. Deletion is strictly bounded to the listed
 * paths: there is NO directory traversal, globbing, or empty-directory pruning
 * (Req 3.2, and the design "Empty-directory cleanup — design decision": the
 * script deliberately leaves now-empty `lib/` directories in place to keep the
 * destructive blast radius limited to exact manifest paths).
 *
 * Error handling (design "Deletion semantics"):
 *   - `ENOENT` is swallowed — an already-missing listed file is NOT an error;
 *     the loop continues over the remaining paths and the file is counted as
 *     skipped (Req 3.3).
 *   - Any other error is collected and, after every path has been attempted, the
 *     first such error is rethrown. This keeps the deletion complete over the
 *     manifest (a mid-list failure never leaves later listed files behind) while
 *     still surfacing genuine failures to `main`.
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * Return shape: `{ deleted: string[], skipped: string[] }`, where `deleted` is
 * the repo-relative paths actually removed and `skipped` is those that were
 * already absent (`ENOENT`). `main` reports `#deleted` as `deleted.length`.
 *
 * @param {string} repoRoot absolute path to the repo root
 * @param {string[]} paths repo-relative POSIX paths (the manifest `files` list)
 * @returns {{deleted: string[], skipped: string[]}}
 */
export function deleteTargets(repoRoot, paths) {
  const deleted = [];
  const skipped = [];
  let firstError;

  for (const p of paths) {
    const abs = path.resolve(repoRoot, p);
    try {
      fs.unlinkSync(abs);
      deleted.push(p);
    } catch (err) {
      if (err && err.code === 'ENOENT') {
        // Already-missing listed file is not an error (Req 3.3); keep going.
        skipped.push(p);
        continue;
      }
      // Attempt the remaining paths, but remember the first real failure so it
      // can be rethrown once the whole list has been processed.
      if (firstError === undefined) firstError = err;
    }
  }

  if (firstError !== undefined) throw firstError;

  return { deleted, skipped };
}

/**
 * Back up an about-to-be-overwritten `lib/` Base_File into the Base_Backup_Directory
 * (first-write-wins).
 *
 * Per the design "Data Models → Base Backup Model → Location and structure": the
 * backup mirrors the repository-relative path of the source under
 * `<repoRoot>/.flavor-base-backup/`, e.g. `sfera/lib/src/foo.dart` is backed up to
 * `.flavor-base-backup/sfera/lib/src/foo.dart`. This is called by `copyFiles`
 * (task 16.2) right before a Base_File is overwritten, so the source
 * (`resolve(repoRoot, targetRel)`) is expected to exist.
 *
 * First-write-wins (design "Base Backup Model → First-write-wins"): if a backup for
 * `targetRel` ALREADY exists under the backup dir, this does NOTHING and leaves the
 * existing backup untouched — the earliest backup (the true original base) is never
 * clobbered by a later switch. Only when no backup exists yet does it create the
 * intermediate directories (`fs.mkdirSync(..., { recursive: true })`) and copy the
 * current `lib/` file (`fs.copyFileSync`) to the mirrored destination.
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * Return shape: `{ backedUp: boolean }` — `true` when a new backup was written,
 * `false` when the copy was skipped because a backup already existed.
 *
 * @param {string} repoRoot absolute path to the repo root
 * @param {string} targetRel repo-relative POSIX path of the `lib/` file being overwritten
 * @returns {{backedUp: boolean}}
 */
export function backupBaseFile(repoRoot, targetRel) {
  const destAbs = path.resolve(baseBackupDir(repoRoot), targetRel);

  // First-write-wins: never overwrite an existing backup (the true original base).
  if (fs.existsSync(destAbs)) {
    return { backedUp: false };
  }

  const srcAbs = path.resolve(repoRoot, targetRel);
  fs.mkdirSync(path.dirname(destAbs), { recursive: true });
  fs.copyFileSync(srcAbs, destAbs);
  return { backedUp: true };
}

/**
 * Copy every planned file into its `lib/` target, creating intermediate dirs,
 * backing up any overwritten base file, and reporting per-target overwrite status.
 *
 * Consumes the copy plan produced by `planCopy`: an array of
 * `{ source: absolutePath, target: repoRelativePOSIXPath }`. Because `target`
 * is repo-root-relative, `repoRoot` is accepted as a second parameter so the
 * absolute destination can be resolved (`path.resolve(repoRoot, target)`);
 * `planCopy` deliberately keeps targets repo-relative to match the manifest
 * shape, and this is the point where they are re-anchored to disk.
 *
 * `copyFiles` is the single point where an overwrite can happen, so it is also
 * where base backup happens (design "Base-backup during copy (Req 10)"). For
 * each `{ source, target }` entry, in the order produced by `planCopy`:
 *   1. Resolve the absolute destination `destAbs = path.resolve(repoRoot, target)`.
 *   2. Determine `preExisted = fs.existsSync(destAbs)` BEFORE copying — whether
 *      `target` already exists as a Base_File under `lib/` (Req 1.3).
 *   3. If `preExisted`, call `backupBaseFile(repoRoot, target)` to mirror the
 *      current `lib/` file into the Base_Backup_Directory BEFORE overwriting it
 *      (Req 10.1). The backup is first-write-wins (handled inside
 *      `backupBaseFile`), so the true original base is never clobbered.
 *   4. Create missing intermediate target directories
 *      (`fs.mkdirSync(dir, { recursive: true })`) and copy with
 *      `fs.copyFileSync`, overwriting any existing target unconditionally (Req 1.4).
 *   5. Record `{ path: target, overwrote: preExisted }` —
 *      `preExisted === true` ⇒ Overwrite_Entry, `false` ⇒ New_File_Entry
 *      (Req 10.2, 10.3, 10.4).
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * Contract: returns an array of `{ path, overwrote }` entries — one per written
 * Target_File, where `path` is the repo-relative POSIX target and `overwrote`
 * reports whether a pre-existing Base_File was overwritten. This is exactly what
 * `buildManifest(flavor, targets)` consumes.
 *
 * @param {Array<{source: string, target: string}>} copyPlan
 * @param {string} repoRoot absolute path to the repo root (to resolve targets)
 * @returns {Array<{path: string, overwrote: boolean}>} per-target entries that were written
 */
export function copyFiles(copyPlan, repoRoot) {
  const written = [];
  for (const entry of copyPlan) {
    const destAbs = path.resolve(repoRoot, entry.target);
    const preExisted = fs.existsSync(destAbs);
    if (preExisted) {
      backupBaseFile(repoRoot, entry.target);
    }
    fs.mkdirSync(path.dirname(destAbs), { recursive: true });
    fs.copyFileSync(entry.source, destAbs);
    written.push({ path: entry.target, overwrote: preExisted });
  }
  return written;
}

/**
 * Restore `lib/` to its pre-switch base state, then clear the switch bookkeeping
 * (Req 11.1–11.6). Standalone restore-base mode — performs NO flavor switch,
 * spawns NO resolution, and touches the manifest only to clear it.
 *
 * Design: see "## Restore-Base Operation". Sequence:
 *   1. Classify the manifest via {@link readManifest}.
 *   2. Nothing-to-do guard (Req 11.5): if the manifest is NOT VALID (MISSING or
 *      CORRUPT) AND the Base_Backup_Directory is absent or empty, report
 *      "Nothing to restore" to stdout and return 0 WITHOUT mutating any `lib/`.
 *   3. VALID manifest: for each Overwrite_Entry (`overwrote === true`) copy the
 *      Base_Backup_File `<repoRoot>/.flavor-base-backup/<path>` back to
 *      `<repoRoot>/<path>` (mkdir -p the dest dir, `copyFileSync`). A missing
 *      backup file (ENOENT) is tolerated — skip it and count it as skipped
 *      (Req 11.6).
 *   4. VALID manifest: delete every New_File_Entry (`overwrote === false`) target
 *      via {@link deleteTargets} (already tolerant of already-missing files)
 *      (Req 11.2).
 *   5. Cleanup (Req 11.3): "clear" the manifest by removing
 *      `.flavor-manifest.json` (ENOENT-tolerant) — so a subsequent switch is a
 *      clean first-run — and remove the Base_Backup_Directory recursively.
 *
 * Edge case — manifest NOT VALID but the backup dir HAS contents (manifest lost
 * or corrupt while backups survive): the design treats this as an inconsistent
 * state handled conservatively ("restore backups it can, report the
 * inconsistency"). Without the manifest we cannot know which paths were
 * New_File_Entries, so deletion of new files is impossible; we only restore. We
 * walk the backup dir, copy every backup file back to its mirrored repo-relative
 * path, then remove the backup dir and report what was restored. This is
 * documented here because it diverges from the manifest-driven path above.
 *
 * Reporting / exit-code convention: restore-base is a full standalone mode, so
 * rather than returning a result object for a dispatcher to map, this function
 * does its OWN console reporting (summary → stdout, errors → stderr) and RETURNS
 * a numeric exit code — 0 on success (including the nothing-to-do no-op, which is
 * a success per Req 11.5), 1 only on an unexpected hard error. This mirrors how
 * {@link main} itself reports and returns a code, and keeps the function directly
 * testable (invoke against a temp-dir `repoRoot`, assert on the returned code and
 * captured output). It never calls `process.exit`. The task-18 dispatcher simply
 * forwards this return value as the process exit code.
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * @param {string} repoRoot absolute path to the repo root
 * @returns {number} exit code — 0 on success / nothing-to-do, 1 on hard error
 */
export function restoreBase(repoRoot) {
  try {
    const backupDir = baseBackupDir(repoRoot);

    // Does the Base_Backup_Directory have any contents? (absent or empty = none)
    let backupEntries = [];
    try {
      backupEntries = fs.readdirSync(backupDir);
    } catch (err) {
      if (!(err && err.code === 'ENOENT')) throw err;
      // Absent dir → treated as empty (backupEntries stays []).
    }
    const backupHasContents = backupEntries.length > 0;

    const state = readManifest(repoRoot);

    // Nothing-to-do guard (Req 11.5): no readable manifest AND no backup contents
    // → nothing to undo. Report and succeed without touching any lib/ folder.
    if (state.state !== 'VALID' && !backupHasContents) {
      console.log('Nothing to restore');
      return 0;
    }

    let restored = 0;
    let removed = 0;
    let skipped = 0;

    if (state.state === 'VALID') {
      // 3. Restore every Overwrite_Entry from its Base_Backup_File.
      for (const entry of state.files) {
        if (entry.overwrote !== true) continue;
        const backupAbs = path.resolve(backupDir, entry.path);
        const destAbs = path.resolve(repoRoot, entry.path);
        try {
          fs.mkdirSync(path.dirname(destAbs), { recursive: true });
          fs.copyFileSync(backupAbs, destAbs);
          restored++;
        } catch (err) {
          // Tolerate a missing backup file (Req 11.6): skip and continue.
          if (err && err.code === 'ENOENT') {
            skipped++;
            continue;
          }
          throw err;
        }
      }

      // 4. Delete every New_File_Entry target (tolerant of already-missing).
      const newPaths = state.files.filter((e) => e.overwrote === false).map((e) => e.path);
      const del = deleteTargets(repoRoot, newPaths);
      removed = del.deleted.length;
    } else {
      // Edge case: manifest NOT VALID but the backup dir has contents. We cannot
      // know which paths were new files, so we only restore: walk the backup dir
      // and copy each backup file back to its mirrored repo-relative path.
      const walk = (currentDir) => {
        for (const dirent of fs.readdirSync(currentDir, { withFileTypes: true })) {
          const abs = path.join(currentDir, dirent.name);
          if (dirent.isDirectory()) {
            walk(abs);
          } else if (dirent.isFile()) {
            const relFromBackup = path.relative(backupDir, abs);
            const destAbs = path.resolve(repoRoot, relFromBackup);
            fs.mkdirSync(path.dirname(destAbs), { recursive: true });
            fs.copyFileSync(abs, destAbs);
            restored++;
          }
        }
      };
      walk(backupDir);
      console.error(
        'Warning: manifest missing or corrupt but base backups exist; restored backups only ' +
          '(new-file entries cannot be determined without a valid manifest)',
      );
    }

    // 5. Cleanup (Req 11.3): clear the manifest (remove the file so a later switch
    //    is a clean first-run) and remove the Base_Backup_Directory recursively.
    fs.rmSync(manifestPath(repoRoot), { force: true });
    fs.rmSync(backupDir, { recursive: true, force: true });

    // 7. Report the summary to stdout and succeed.
    console.log(
      `Restored base: ${restored} file(s) restored, ${removed} file(s) removed, ` +
        `${skipped} backup(s) skipped (missing)`,
    );
    return 0;
  } catch (err) {
    console.error(`restore-base failed: ${err instanceof Error ? err.message : String(err)}`);
    return 1;
  }
}

/**
 * Seed a flavor folder from an existing `lib/` file (standalone save-to-flavor
 * mode, Req 12.1–12.7). An authoring helper: it COPIES a `<component>/lib/<rest>`
 * source file to `<component>/<flavor>/<rest>`, leaving the source in place. It
 * performs NO flavor switch, touches NEITHER the manifest NOR the
 * Base_Backup_Directory, and spawns NO resolution.
 *
 * Design: see "## Save-to-Flavor Operation". Sequence (every validation runs
 * BEFORE any write, so an invalid invocation never creates or modifies a file —
 * Req 12.5, 12.6, 12.7):
 *   1. Validate `flavor` ∈ {@link FLAVORS}. Although `parseCliArgs` already
 *      validates this, `saveToFlavor` is an exported entry point and re-validates
 *      defensively: invalid → report to stderr, return 1, no copy (Req 12.5).
 *   2. Validate the source path shape via {@link deriveFlavorDest}: `file` must be
 *      a `<component>/lib/<rest>` path. If `{ ok: false }` → report to stderr,
 *      return 1, no copy (Req 12.7).
 *   3. Validate the source file exists on disk under `lib/`:
 *      `srcAbs = path.resolve(repoRoot, file)` must exist and be a regular file.
 *      Missing (or not a file) → report to stderr, return 1, no copy (Req 12.6).
 *   4. `destRel = deriveFlavorDest(file, flavor).dest`,
 *      `destAbs = path.resolve(repoRoot, destRel)`. Note `destExisted` BEFORE
 *      writing (for the overwrite report, Req 12.4).
 *   5. `mkdir -p dirname(destAbs)`, then `fs.copyFileSync(srcAbs, destAbs)` —
 *      overwriting any existing destination (Req 12.1, 12.4). This is a COPY: the
 *      source file is left in place under `lib/` (Req 12.3).
 *   6. Report success to stdout; if `destExisted`, note the overwrite (Req 12.4).
 *      Return 0.
 *
 * Reporting / exit-code convention: like {@link restoreBase}, save-to-flavor is a
 * full standalone mode, so rather than returning a result object for a dispatcher
 * to map, this function does its OWN console reporting (summary → stdout, errors →
 * stderr) and RETURNS a numeric exit code — 0 on success, 1 on any validation or
 * hard failure. This mirrors {@link restoreBase}/{@link main} and keeps the
 * function directly testable (invoke against a temp-dir `repoRoot`, assert on the
 * returned code and captured output). It never calls `process.exit`; the task-18
 * dispatcher simply forwards this return value as the process exit code.
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * @param {string} repoRoot absolute path to the repo root
 * @param {string} flavor the target flavor (one of {@link FLAVORS})
 * @param {string} file repo-relative POSIX source path (`<component>/lib/<rest>`)
 * @returns {number} exit code — 0 on success, 1 on invalid input / hard error
 */
export function saveToFlavor(repoRoot, flavor, file) {
  try {
    // 1. Validate the flavor (defensive — see JSDoc). No I/O before this passes.
    if (!FLAVORS.includes(flavor)) {
      console.error(`Not a valid flavor: '${flavor}' (expected ${FLAVORS.join('|')})`);
      return 1;
    }

    // 2. Validate the source path shape (<component>/lib/<rest>).
    const derived = deriveFlavorDest(file, flavor);
    if (!derived.ok) {
      console.error(`Source path is not a lib/ path of a workspace component: '${file}'`);
      return 1;
    }

    // 3. Validate the source file exists on disk under lib/ (and is a regular file).
    const srcAbs = path.resolve(repoRoot, file);
    let srcStat;
    try {
      srcStat = fs.statSync(srcAbs);
    } catch {
      srcStat = undefined;
    }
    if (srcStat === undefined || !srcStat.isFile()) {
      console.error(`Source file not found: '${file}'`);
      return 1;
    }

    // 4. Compute the destination and note whether it already exists (for the
    //    overwrite report). All validation above passed, so a write may happen now.
    const destRel = derived.dest;
    const destAbs = path.resolve(repoRoot, destRel);
    const destExisted = fs.existsSync(destAbs);

    // 5. mkdir -p the dest dir, then COPY the lib/ file into the flavor folder,
    //    overwriting any existing destination. The source is left in place (Req 12.3).
    fs.mkdirSync(path.dirname(destAbs), { recursive: true });
    fs.copyFileSync(srcAbs, destAbs);

    // 6. Report success (noting an overwrite when the destination pre-existed).
    if (destExisted) {
      console.log(`Copied '${file}' to '${destRel}' (overwrote existing destination)`);
    } else {
      console.log(`Copied '${file}' to '${destRel}'`);
    }
    return 0;
  } catch (err) {
    console.error(`save-to-flavor failed: ${err instanceof Error ? err.message : String(err)}`);
    return 1;
  }
}

/**
 * Save EVERY Git-changed `lib/` file into the matching flavor folder in one
 * command — the `--save-to-flavor=<flavor> --all` form (Req 13.1–13.8).
 *
 * Standalone authoring helper, exactly like {@link saveToFlavor}: it performs NO
 * flavor switch, does NOT read or write the Flavor_Manifest or the
 * Base_Backup_Directory, and spawns NO resolution. It reuses the single-file
 * destination derivation ({@link deriveFlavorDest}) and the same copy-with-overwrite
 * semantics per present file, and additionally mirrors working-tree deletions into
 * the flavor folder. See design "## Save-to-Flavor Operation → Save-all form".
 *
 * Algorithm (design "#### `saveAllToFlavor` algorithm"):
 *   1. Defensively validate the flavor against {@link FLAVORS} (parseCliArgs also
 *      validates, but this is an exported entry point). Invalid → stderr, return 1
 *      (Req 13.6).
 *   2. Collect the Git working-tree changes via {@link gitChangedLibFiles}, passing
 *      through the injected `spawn` (defaulting to {@link spawnSync}) so tests can
 *      fake git. Git unavailable / not a repository → stderr, return 1, no mutation
 *      (Req 13.7).
 *   3. Keep only `<component>/lib/<rest>` paths, using `deriveFlavorDest` as the
 *      single source of truth for "is a lib path" (Req 13.2).
 *   4. No changed `lib/` files → report "No changed lib/ files to save" to stdout,
 *      return 0, copying/deleting nothing (Req 13.8).
 *   5. For each change, derive its flavor destination and:
 *        - `present`: resolve the source under `lib/`; if it exists, mkdir -p the
 *          dest dir and COPY (overwrite), leaving the source in place (Req 13.3). A
 *          present-but-vanished entry (listed by Git but absent on disk) is treated
 *          like a deletion for safety.
 *        - `deleted`: delete the derived flavor destination iff it exists (Req 13.4);
 *          otherwise leave the flavor folder unchanged for that path (Req 13.5).
 *   6. Report a summary to stdout; return 0 (Req 13.1).
 *
 * Reporting / exit-code convention: like {@link saveToFlavor} and {@link restoreBase},
 * this is a full standalone mode, so it does its OWN console reporting (summary →
 * stdout, errors → stderr) and RETURNS a numeric exit code — 0 on success /
 * nothing-to-do, 1 on invalid input or a hard git failure. It never calls
 * `process.exit`; the dispatcher (task 28) forwards this return value as the process
 * exit code.
 *
 * Uses synchronous fs (consistent with the rest of this module).
 *
 * @param {string} repoRoot absolute path to the repo root
 * @param {string} flavor the target flavor (one of {@link FLAVORS})
 * @param {{spawn?: Function}} [options] optional injected git spawn (defaults to {@link spawnSync})
 * @returns {number} exit code — 0 on success / nothing-to-do, 1 on invalid input / hard error
 */
export function saveAllToFlavor(repoRoot, flavor, { spawn } = {}) {
  try {
    // 1. Defensive flavor validation (Req 13.6). No I/O before this passes.
    if (!FLAVORS.includes(flavor)) {
      console.error(`Not a valid flavor: '${flavor}' (expected ${FLAVORS.join('|')})`);
      return 1;
    }

    // 2. Collect Git working-tree changes, forwarding the injected spawn so tests
    //    can fake git. A git-unavailable / not-a-repo result is a hard error with
    //    no mutation (Req 13.7).
    const changed = gitChangedLibFiles(repoRoot, spawn ?? spawnSync);
    if (!changed.ok) {
      console.error('Could not determine Git state (is this a Git repository and is git installed?)');
      return 1;
    }

    // 3. Keep only <component>/lib/<rest> paths, reusing deriveFlavorDest as the
    //    single source of truth for "is a lib path" (Req 13.2). Carry the derived
    //    destination alongside each entry so step 5 does not re-derive.
    const libChanges = [];
    for (const entry of changed.files) {
      const d = deriveFlavorDest(entry.path, flavor);
      if (d.ok) {
        libChanges.push({ path: entry.path, status: entry.status, dest: d.dest });
      }
    }

    // 4. Nothing to do → no mutation, exit 0 (Req 13.8).
    if (libChanges.length === 0) {
      console.log('No changed lib/ files to save');
      return 0;
    }

    // 5. Apply each change to the flavor folder.
    let copied = 0;
    let overwritten = 0;
    let removed = 0;

    for (const change of libChanges) {
      const destAbs = path.resolve(repoRoot, change.dest);

      if (change.status === 'present') {
        const srcAbs = path.resolve(repoRoot, change.path);
        // Guard against a present-but-vanished race: if the source is gone, treat
        // it like a deletion for safety rather than copying a missing file.
        if (!fs.existsSync(srcAbs)) {
          if (fs.existsSync(destAbs)) {
            fs.unlinkSync(destAbs);
            removed += 1;
          }
          continue;
        }
        const destExisted = fs.existsSync(destAbs);
        fs.mkdirSync(path.dirname(destAbs), { recursive: true });
        fs.copyFileSync(srcAbs, destAbs); // COPY: source stays in lib/ (Req 13.3)
        copied += 1;
        if (destExisted) overwritten += 1;
      } else {
        // status === 'deleted': remove the flavor file iff it exists (Req 13.4);
        // otherwise leave the flavor folder unchanged for this path (Req 13.5).
        if (fs.existsSync(destAbs)) {
          fs.unlinkSync(destAbs);
          removed += 1;
        }
      }
    }

    // 6. Summary → stdout, exit 0 (Req 13.1).
    console.log(
      `Saved ${libChanges.length} changed lib/ file(s) to flavor '${flavor}': ` +
        `${copied} copied (${overwritten} overwritten), ${removed} removed from flavor`,
    );
    return 0;
  } catch (err) {
    console.error(`save-to-flavor --all failed: ${err instanceof Error ? err.message : String(err)}`);
    return 1;
  }
}

/**
 * Build a manifest object (schema v2) from a flavor and the copied targets (pure).
 *
 * Per the design "Data Models / Manifest Data Model → Schema (version 2 — breaking
 * change)": the manifest records, per entry, whether a Target_File overwrote a
 * pre-existing Base_File. The v1 `files: string[]` shape could not carry that
 * distinction, so the schema is bumped to {@link MANIFEST_VERSION} (`2`) and
 * `files` becomes an array of `{ path, overwrote }` objects.
 *
 * Input: `targets` is the array returned by the extended `copyFiles` (task 16.2) —
 * one `{ path: string, overwrote: boolean }` entry per written Target_File, where
 * `path` is a repo-root-relative path and `overwrote` is `true` for an
 * Overwrite_Entry (a Base_Backup_File exists) and `false` for a New_File_Entry.
 *
 * Output: `{ version: 2, flavor, generatedAt, files }` where each `files` entry is
 * `{ path, overwrote }` with `path` normalized to forward slashes (repo-root-relative
 * POSIX) and `overwrote` carried through verbatim. `flavor` is recorded verbatim and
 * `generatedAt` is `new Date().toISOString()` (ISO-8601, diagnostic only). Pure, no I/O.
 *
 * @param {string} flavor one of {@link FLAVORS}
 * @param {Array<{path: string, overwrote: boolean}>} targets per-target entries from `copyFiles`
 * @returns {{version: number, flavor: string, generatedAt: string, files: Array<{path: string, overwrote: boolean}>}}
 */
export function buildManifest(flavor, targets) {
  return {
    version: MANIFEST_VERSION,
    flavor,
    generatedAt: new Date().toISOString(),
    files: targets.map((entry) => ({
      path: entry.path.replace(/\\/g, '/'),
      overwrote: entry.overwrote,
    })),
  };
}

/**
 * Serialize the manifest to `<repoRoot>/.flavor-manifest.json`, fully replacing
 * any prior contents (Req 2.1, 2.4).
 *
 * Resolves the destination via the existing `manifestPath(repoRoot)` helper and
 * writes `JSON.stringify(manifest, null, 2)` with a trailing newline using
 * `fs.writeFileSync`. Uses synchronous fs (consistent with the rest of this
 * module).
 *
 * @param {string} repoRoot
 * @param {object} manifest
 */
export function writeManifest(repoRoot, manifest) {
  fs.writeFileSync(manifestPath(repoRoot), `${JSON.stringify(manifest, null, 2)}\n`);
}

/**
 * Collect the set of keys declared directly under the top-level `dependencies:`
 * mapping of a pubspec document. Dependency-free, read-only structural scan used
 * ONLY to verify a mutation — never to emit text.
 *
 * It walks lines, finds the top-level `dependencies:` key (zero indentation),
 * then records every key whose indentation is exactly one level deeper than the
 * `dependencies` key and is a direct child (not a nested value under another
 * key). The scan stops at the next line at the same indentation as
 * `dependencies:` (the next top-level key) or EOF. Comment and blank lines are
 * ignored.
 *
 * @param {string} text pubspec document text
 * @returns {Set<string>|null} the direct dependency keys, or null if there is no
 *   top-level `dependencies:` mapping
 */
function collectDependencyKeys(text) {
  const lines = text.split('\n');
  let depIndent = -1; // indentation of the `dependencies:` key line
  let childIndent = -1; // indentation of a direct child key (first one seen)
  let inDeps = false;
  const keys = new Set();

  for (const line of lines) {
    // Skip blank lines and whole-line comments; they don't affect structure.
    const trimmed = line.trim();
    if (trimmed === '' || trimmed.startsWith('#')) continue;

    const indent = line.length - line.trimStart().length;

    if (!inDeps) {
      if (indent === 0 && /^dependencies:\s*$/.test(line)) {
        inDeps = true;
        depIndent = indent;
      }
      continue;
    }

    // We're inside the dependencies block.
    if (indent <= depIndent) {
      // Dedented back to (or past) the `dependencies:` level → block ended.
      break;
    }

    if (childIndent === -1) {
      // The first non-blank, non-comment line sets the direct-child indent.
      childIndent = indent;
    }

    if (indent === childIndent) {
      // Direct child of `dependencies:` — capture its key.
      const m = /^\s*([^\s:#]+):/.exec(line);
      if (m) keys.add(m[1]);
    }
    // Lines more deeply indented than childIndent are values of the current
    // entry (e.g. `sdk: flutter` under `flutter:`), not direct dep keys.
  }

  return inDeps ? keys : null;
}

/**
 * Remove a single workspace-package line from pubspec text (pure,
 * comment-preserving).
 *
 * Strategy (design "pubspec.yaml Edit Strategy" — targeted line-based removal
 * with structural verification):
 *   1. Locate the `# workspace packages` comment line.
 *   2. Walk the contiguous run of indented `key: value` entries that follows it.
 *      The block ends at the first blank line, a dedent, or the next comment
 *      group (e.g. the `# https://pub.dev/...` entries).
 *   3. Within that block, find the line matching `^<indent><pkg>:\s` and remove
 *      exactly that one line, leaving every other byte intact.
 *   4. Verify the result independently of the mutation: the dependency key set
 *      must still be parseable, `<pkg>` must be gone, and every other previous
 *      dependency key must remain. Abort if verification fails.
 *
 * Pure text-in/text-out, no filesystem access.
 *
 * Return shape (discriminated union consumed by main() in task 10.2):
 *   - { ok: true,  text }                        — line removed, verified
 *   - { ok: false, reason: 'not_found' }         — pkg absent from the block
 *   - { ok: false, reason: 'verification_failed' } — post-removal check failed
 *
 * @param {string} pubspecText
 * @param {string} pkg
 * @returns {{ok: true, text: string} | {ok: false, reason: 'not_found' | 'verification_failed'}}
 */
export function removeWorkspaceDep(pubspecText, pkg) {
  // Preserve the original line terminators by splitting without a regex and
  // reassembling with '\n'. (pubspec files in this repo use '\n'.)
  const lines = pubspecText.split('\n');

  // 1. Find the `# workspace packages` marker line.
  let markerIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (/^\s*#\s*workspace packages\s*$/.test(lines[i])) {
      markerIdx = i;
      break;
    }
  }
  if (markerIdx === -1) {
    return { ok: false, reason: 'not_found' };
  }

  // 2. Walk the contiguous run of indented `key: value` entries after the
  //    marker. The block is the maximal run of entry lines; it ends at the
  //    first blank line, a dedent below the block indent, or a comment line.
  let targetIdx = -1;
  let blockIndent = -1;
  for (let i = markerIdx + 1; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // Blank line → block ends.
    if (trimmed === '') break;
    // Comment line (e.g. the next `# https://pub.dev/...` group) → block ends.
    if (trimmed.startsWith('#')) break;

    const indent = line.length - line.trimStart().length;
    if (blockIndent === -1) {
      blockIndent = indent;
    } else if (indent < blockIndent) {
      // Dedent below the block → block ends.
      break;
    } else if (indent > blockIndent) {
      // Deeper indentation is a nested value of the previous entry, not a new
      // workspace-package key; keep scanning but never treat it as the target.
      continue;
    }

    // 3. Match the dependency key line `^<indent><pkg>:\s`.
    if (indent === blockIndent) {
      const m = /^\s*([^\s:#]+):/.exec(line);
      if (m && m[1] === pkg) {
        targetIdx = i;
        break;
      }
    }
  }

  if (targetIdx === -1) {
    return { ok: false, reason: 'not_found' };
  }

  // 4a. Capture the pre-mutation dependency key set for the verification check.
  const before = collectDependencyKeys(pubspecText);

  // 4b. Perform the mutation: remove exactly the one target line.
  const mutatedLines = lines.slice(0, targetIdx).concat(lines.slice(targetIdx + 1));
  const mutatedText = mutatedLines.join('\n');

  // 4c. Verify independently of the mutation.
  const after = collectDependencyKeys(mutatedText);
  if (before === null || after === null) {
    return { ok: false, reason: 'verification_failed' };
  }
  // The removed key must be absent and must have been present before.
  if (!before.has(pkg) || after.has(pkg)) {
    return { ok: false, reason: 'verification_failed' };
  }
  // Every other previous dependency key must remain present.
  for (const key of before) {
    if (key === pkg) continue;
    if (!after.has(key)) {
      return { ok: false, reason: 'verification_failed' };
    }
  }
  // No new keys should have appeared (removal only).
  if (after.size !== before.size - 1) {
    return { ok: false, reason: 'verification_failed' };
  }

  return { ok: true, text: mutatedText };
}

/**
 * Discover the set of Git-changed `lib/` files (working-tree vs HEAD) and
 * classify each as present or deleted — the Changed_Lib_Files that the
 * `--save-to-flavor --all` form (Req 13) saves (via `saveAllToFlavor`, task 27).
 *
 * Per the design "Save-all form → Collecting Changed_Lib_Files from Git": the
 * full set of staged, unstaged, and untracked changes is captured with a single
 * `git status --porcelain -z` invocation (NUL-separated so paths with spaces and
 * rename records parse unambiguously). All git calls go through the injected
 * `spawn` (defaulting to `spawnSync`) with `{ encoding: 'utf8' }` so the test
 * suite can supply a fake and exercise every branch without a real repository.
 *
 * Sequence:
 *   1. Resolve the Git top-level with `git -C <repoRoot> rev-parse
 *      --show-toplevel`. If the spawn errors (e.g. git not on PATH) or exits
 *      non-zero (not a Git repository), return the failure signal
 *      `{ ok: false, reason: 'git_unavailable' }` (Req 13.7). The trimmed stdout
 *      is the absolute top-level path.
 *   2. Run `git -C <repoRoot> status --porcelain -z`. Same failure signal on
 *      spawn error or non-zero exit.
 *   3. Parse the NUL-separated porcelain v1 records. Each record is
 *      `XY<space>PATH` (`XY` = two-char index/worktree status). For a rename
 *      (`R`) or copy (`C`) record, the ORIGINAL path follows as a SEPARATE
 *      NUL-terminated field: the NEW path is treated as a changed path and the
 *      OLD path is classified `deleted`.
 *
 * Path handling (design "Repo-root vs Git top-level"): porcelain paths are
 * relative to the Git TOP-LEVEL, which may differ from `repoRoot` (a
 * subdirectory of a larger repo). Each path is resolved to an absolute path
 * against the top-level, then re-expressed as a `repoRoot`-relative POSIX path;
 * any path that lands outside `repoRoot` is dropped.
 *
 * Classification (design): rather than decode every porcelain `XY` edge case,
 * the present/deleted status is decided by ON-DISK existence relative to
 * `repoRoot` — a path that still exists in the working tree is `present`, a path
 * that is gone is `deleted`. Porcelain is parsed only to enumerate the set of
 * changed paths; disk existence is the authoritative classifier (and the
 * de-duplication tie-breaker when a path shows up from multiple columns).
 *
 * lib/ filter (Req 13.2): only paths that qualify as `<component>/lib/<rest>`
 * are kept, using {@link deriveFlavorDest} as the single source of truth for
 * lib-path shape (same definition as the single-file save form). The flavor
 * argument is irrelevant to the filter — only the ok/not-ok result is used — so
 * `FLAVORS[0]` is passed as a placeholder.
 *
 * Return shape (discriminated union consumed by `saveAllToFlavor`, task 27):
 *   - { ok: true, files: Array<{ path: string, status: 'present' | 'deleted' }> }
 *       — `path` is a `repoRoot`-relative POSIX `<component>/lib/<rest>` path,
 *       de-duplicated; empty output yields `{ ok: true, files: [] }`.
 *   - { ok: false, reason: 'git_unavailable' } — git could not be spawned or
 *       `repoRoot` is not a Git repository (Req 13.7).
 *
 * @param {string} repoRoot absolute path to the repo root (git cwd / `-C` target)
 * @param {(cmd: string, args: string[], opts: object) => {status: number|null, stdout?: string, error?: Error}} [spawn]
 *   injectable spawn function; defaults to `spawnSync`
 * @returns {{ok: true, files: Array<{path: string, status: 'present' | 'deleted'}>} | {ok: false, reason: 'git_unavailable'}}
 */
export function gitChangedLibFiles(repoRoot, spawn = spawnSync) {
  // 1. Resolve the Git top-level. A spawn error (git missing) or non-zero exit
  //    (not a repo) is a hard git-unavailable failure (Req 13.7).
  const topLevelResult = spawn('git', ['-C', repoRoot, 'rev-parse', '--show-toplevel'], {
    encoding: 'utf8',
  });
  if (!topLevelResult || topLevelResult.error || topLevelResult.status !== 0) {
    return { ok: false, reason: 'git_unavailable' };
  }
  const topLevel = String(topLevelResult.stdout ?? '').trim();

  // 2. Capture staged + unstaged + untracked changes in one NUL-separated pass.
  const statusResult = spawn('git', ['-C', repoRoot, 'status', '--porcelain', '-z'], {
    encoding: 'utf8',
  });
  if (!statusResult || statusResult.error || statusResult.status !== 0) {
    return { ok: false, reason: 'git_unavailable' };
  }
  const raw = String(statusResult.stdout ?? '');

  // 3. Parse the porcelain v1 `-z` stream into a set of top-level-relative paths.
  //    Records are NUL-separated; a rename/copy record consumes an extra
  //    NUL-terminated field holding the original path.
  const tokens = raw.split('\0');
  const topLevelRelPaths = new Set();
  for (let i = 0; i < tokens.length; i++) {
    const record = tokens[i];
    if (!record) continue; // trailing empty token after the final NUL

    // Each record is `XY<space>PATH`. The status field is the first two chars;
    // the path begins after the following space (char index 3).
    const statusCode = record.slice(0, 2);
    const recPath = record.slice(3);
    if (recPath) topLevelRelPaths.add(recPath);

    // Rename/copy: the ORIGINAL path is the next NUL-separated field. Consume it
    // and treat it as a changed path too (it will classify as deleted on disk).
    const indexStatus = statusCode[0];
    if (indexStatus === 'R' || indexStatus === 'C') {
      const original = tokens[i + 1];
      if (original) topLevelRelPaths.add(original);
      i += 1; // skip the consumed original-path field
    }
  }

  // 4. Relativize to repoRoot (porcelain paths are top-level-relative), filter to
  //    <component>/lib/<rest> paths, and classify present/deleted by on-disk
  //    existence. A Map de-duplicates paths that appear from multiple columns.
  const flavorPlaceholder = FLAVORS[0];
  const byPath = new Map();
  for (const topRel of topLevelRelPaths) {
    const abs = path.resolve(topLevel, topRel);
    const relToRepo = path.relative(repoRoot, abs);
    // Outside repoRoot → cannot be a <component>/lib/ path of this workspace.
    if (relToRepo.startsWith('..') || path.isAbsolute(relToRepo)) continue;

    const relPosix = relToRepo.split(path.sep).join('/');
    if (!deriveFlavorDest(relPosix, flavorPlaceholder).ok) continue;

    const status = fs.existsSync(abs) ? 'present' : 'deleted';
    byPath.set(relPosix, status);
  }

  const files = Array.from(byPath, ([p, status]) => ({ path: p, status }));
  return { ok: true, files };
}

/** The canonical workspace-resolution command string, for reporting to the developer. */
export const RESOLUTION_COMMAND = 'fvm dart run melos bootstrap';

/**
 * Trigger a workspace-resolution refresh by spawning the project's Melos
 * bootstrap command (Req 8.1, 8.2).
 *
 * Per the design "Workspace Resolution": the canonical command for this
 * Melos-managed Dart workspace is `fvm dart run melos bootstrap`. It is spawned
 * with `cwd = repoRoot` and `stdio: 'inherit'` so the developer sees resolution
 * progress live. The script does NOT silently continue on failure — it returns a
 * discriminated result that `main` (task 10.2) maps to an exit code and uses to
 * print the exact command the developer must run. This function never calls
 * `process.exit`.
 *
 * The spawn is injected (second parameter, defaulting to `spawnSync`) so the
 * test suite can substitute a fake and exercise the success, non-zero-exit, and
 * unavailable-toolchain branches without running the real toolchain.
 *
 * Outcome classification:
 *   - spawn error — the command could not be spawned at all (toolchain
 *     unavailable; `spawnSync` returns an object with an `error`, typically
 *     `ENOENT` for a missing `fvm`). Returns `{ ok: false, reason: 'spawn_error' }`
 *     carrying the exact command so `main` can tell the developer to run
 *     `fvm dart run melos bootstrap` (or `dart pub get` as the lower-level
 *     equivalent) manually (Req 8.1).
 *   - non-zero exit — the command ran but `result.status !== 0`. Returns
 *     `{ ok: false, reason: 'nonzero_exit', status }` (Req 8.2).
 *   - success — `result.status === 0`. Returns `{ ok: true }`.
 *
 * Return shape (discriminated union consumed by main()):
 *   - { ok: true }
 *   - { ok: false, reason: 'spawn_error',  command: string, error: Error }
 *   - { ok: false, reason: 'nonzero_exit', command: string, status: number }
 *
 * @param {string} repoRoot absolute path to the repo root (used as spawn cwd)
 * @param {(cmd: string, args: string[], opts: object) => {status: number|null, error?: Error}} [spawn]
 *   injectable spawn function; defaults to `spawnSync`
 * @returns {{ok: true} | {ok: false, reason: 'spawn_error', command: string, error: Error} | {ok: false, reason: 'nonzero_exit', command: string, status: number}}
 */
export function refreshResolution(repoRoot, spawn = spawnSync) {
  const result = spawn('fvm', ['dart', 'run', 'melos', 'bootstrap'], {
    cwd: repoRoot,
    stdio: 'inherit',
  });

  // The command could not be spawned at all (e.g. `fvm` not on PATH → ENOENT).
  if (result && result.error) {
    return { ok: false, reason: 'spawn_error', command: RESOLUTION_COMMAND, error: result.error };
  }

  // The command ran but exited non-zero (Req 8.2).
  if (!result || result.status !== 0) {
    return {
      ok: false,
      reason: 'nonzero_exit',
      command: RESOLUTION_COMMAND,
      status: result ? result.status : null,
    };
  }

  return { ok: true };
}

/**
 * Dispatch the requested operating mode and map every outcome to an exit code.
 *
 * This is the composition root for the pure/side-effect helpers above. It first
 * dispatches to exactly one operating mode in the fixed precedence from the
 * design "## CLI Interface" → "### Mode dispatch and precedence": `--help`/`-h`
 * → `--restore-base` (forwards {@link restoreBase}, ignoring any flavor
 * positional, `--remove-dep`, and `--save-to-flavor`) → `--save-to-flavor`
 * (forwards {@link saveToFlavor}, ignoring `--remove-dep`) → otherwise the
 * normal flavor switch. The restore-base and save-to-flavor functions do their
 * own reporting and return an exit code, which `main` forwards unchanged.
 *
 * For the normal switch it owns the ordering guarantees from the design
 * "Flavor-Switch Sequence" and the "Error Handling and Exit Codes" matrix
 * (Req 2.3, 3.1, 4.3, 6.3, 6.4, 7.4, 8.1, 8.2). Crucially it does NOT call
 * `process.exit` — it RETURNS a numeric exit code (0 success, 1 failure). The
 * CLI entry wiring (task 11) is the only place that calls
 * `process.exit(main(...))`. This keeps `main` directly testable: tests invoke
 * it against a temp-dir `repoRoot` and assert on the returned code and captured
 * console output.
 *
 * `repoRoot` and `spawn` are injected (second parameter) so fixture-based tests
 * can run the full orchestration against a temp repo and substitute the
 * workspace-resolution spawn. The real `repoRoot` is wired only in task 11.
 *
 * Output channels: human-readable summary → stdout (`console.log`); all errors
 * and the "deletion skipped" note → stderr (`console.error`).
 *
 * @param {string[]} argv full argv (e.g. `process.argv`); first two entries skipped
 * @param {{repoRoot?: string, spawn?: Function}} [deps] injected dependencies
 * @param {string} [deps.repoRoot] absolute path to the repo root
 * @param {Function} [deps.spawn] injectable spawn passed to {@link refreshResolution}
 * @returns {number} process exit code — 0 on success, 1 on any failure
 */
export function main(argv, { repoRoot, spawn } = {}) {
  // 1. Parse + validate args. Invalid input must not mutate anything.
  const args = parseCliArgs(argv);
  if (!args.ok) {
    console.error(args.error);
    return 1;
  }

  // 2. --help/-h: print usage and succeed without touching the filesystem.
  if (args.help) {
    console.log(usageText());
    return 0;
  }

  // 2b. Standalone-mode dispatch (design "## CLI Interface" → "### Mode dispatch
  //     and precedence"). Exactly one mode runs per invocation, in a fixed
  //     precedence AFTER help and BEFORE the normal switch logic:
  //       help → restore-base → save-to-flavor → switch.
  //     Each standalone function does its OWN stdout/stderr reporting and returns
  //     the exit code, so `main` just forwards that return value.

  // 2b-i. --restore-base: revert lib/ to its base state. Ignores any flavor
  //        positional, --remove-dep, and --save-to-flavor (parseCliArgs already
  //        rejected the restore-base + save-to-flavor conflict).
  if (args.restoreBase) {
    return restoreBase(repoRoot);
  }

  // 2b-ii. --save-to-flavor: seed a flavor folder from existing lib/ file(s).
  //         Ignores --remove-dep. Routes by the --all modifier (design
  //         "## CLI Interface" → Mode dispatch and precedence, step 3):
  //           with --all    → save every Git-changed lib/ file at once.
  //           without --all → save the single positional source file.
  if (args.saveToFlavor) {
    if (args.saveToFlavor.all) {
      return saveAllToFlavor(repoRoot, args.saveToFlavor.flavor, { spawn });
    }
    return saveToFlavor(repoRoot, args.saveToFlavor.flavor, args.saveToFlavor.file);
  }

  // 3. Discover workspace components.
  const components = discoverComponents(repoRoot);

  // 4. Build the copy plan BEFORE any mutation. An empty plan means no
  //    component owns a folder for the selected flavor → report + exit 1 with
  //    no filesystem changes (Req 6.3, 6.4).
  const copyPlan = components.flatMap((c) => planCopy(c.dir, args.flavor, repoRoot));
  if (copyPlan.length === 0) {
    console.error(`No matching flavor folder found for flavor '${args.flavor}'`);
    return 1;
  }

  // 4b. --dry-run: run the read-only steps (discovery, planning, manifest diff,
  //     and a non-destructive pubspec probe) and PRINT what the real run WOULD
  //     do, then succeed WITHOUT any filesystem mutation. Nothing below this
  //     block (deleteTargets, copyFiles, writeManifest, pubspec write,
  //     refreshResolution) runs in dry-run mode.
  if (args.dryRun) {
    console.log(`[dry-run] Preview switch to flavor '${args.flavor}' (no changes will be made)`);

    // Files that WOULD be copied (the plan's repo-relative target paths).
    const wouldCopy = copyPlan.map((e) => e.target);
    console.log(`[dry-run] ${wouldCopy.length} file(s) would be copied:`);
    for (const target of wouldCopy) {
      console.log(`[dry-run]   + ${target}`);
    }

    // Files that WOULD be deleted: the prior manifest targets when VALID.
    const manifest = readManifest(repoRoot);
    if (manifest.state === 'VALID') {
      console.log(`[dry-run] ${manifest.files.length} file(s) would be deleted:`);
      for (const entry of manifest.files) {
        console.log(`[dry-run]   - ${entry.path}`);
      }
    } else {
      const reason = manifest.state === 'MISSING' ? 'no prior manifest' : 'corrupt manifest';
      console.log(`[dry-run] deletion would be skipped (${reason})`);
    }

    // Dependency removal probe: report whether the line WOULD be removed,
    // WITHOUT writing the file or spawning resolution.
    if (args.removeDep) {
      const pubspecPath = path.join(repoRoot, 'app', 'pubspec.yaml');
      let pubspecText;
      try {
        pubspecText = fs.readFileSync(pubspecPath, 'utf8');
      } catch (err) {
        console.error(`Failed to read ${pubspecPath}: ${err instanceof Error ? err.message : err}`);
        return 1;
      }
      const res = removeWorkspaceDep(pubspecText, args.removeDep);
      if (res.ok) {
        console.log(
          `[dry-run] workspace package '${args.removeDep}' would be removed from app/pubspec.yaml (found)`,
        );
      } else if (res.reason === 'not_found') {
        console.log(
          `[dry-run] workspace package '${args.removeDep}' would NOT be removed (not_found)`,
        );
      } else {
        console.log(
          `[dry-run] workspace package '${args.removeDep}' would NOT be removed (verification would fail)`,
        );
      }
    }

    return 0;
  }

  // 5. Read the prior manifest and delete only its recorded targets when VALID.
  //    MISSING/CORRUPT skip deletion and report the skip (Req 4.3).
  const manifest = readManifest(repoRoot);
  let deletedCount = 0;
  if (manifest.state === 'VALID') {
    const del = deleteTargets(repoRoot, manifest.files.map((e) => e.path));
    deletedCount = del?.deleted.length ?? 0;
  } else {
    const reason = manifest.state === 'MISSING' ? 'no prior manifest' : 'corrupt manifest';
    console.log(`deletion skipped (${reason})`);
  }

  // 6. Copy the new flavor files (overwrite allowed), collecting target paths.
  const targetPaths = copyFiles(copyPlan, repoRoot);

  // 7. Write a fresh manifest describing exactly this switch's targets.
  writeManifest(repoRoot, buildManifest(args.flavor, targetPaths));

  // 8. Optional workspace-package removal + resolution refresh.
  let depRemoved = false;
  if (args.removeDep) {
    const pubspecPath = path.join(repoRoot, 'app', 'pubspec.yaml');

    // 8a. Read app/pubspec.yaml.
    let pubspecText;
    try {
      pubspecText = fs.readFileSync(pubspecPath, 'utf8');
    } catch (err) {
      console.error(`Failed to read ${pubspecPath}: ${err instanceof Error ? err.message : err}`);
      return 1;
    }

    // 8b. Remove the dependency (comment-preserving). Leave the file unchanged
    //     on any failure (Req 7.3).
    const res = removeWorkspaceDep(pubspecText, args.removeDep);
    if (!res.ok) {
      if (res.reason === 'not_found') {
        console.error(`Workspace package '${args.removeDep}' not found in workspace packages`);
      } else {
        console.error(
          `Failed to remove workspace package '${args.removeDep}': pubspec verification failed`,
        );
      }
      return 1;
    }

    // 8c. Write the mutated pubspec back (Req 7.1, 7.2).
    try {
      fs.writeFileSync(pubspecPath, res.text);
    } catch (err) {
      console.error(`Failed to write ${pubspecPath}: ${err instanceof Error ? err.message : err}`);
      return 1;
    }
    depRemoved = true;

    // 8d. Refresh workspace resolution (Req 8.1, 8.2).
    const r = refreshResolution(repoRoot, spawn);
    if (!r.ok) {
      if (r.reason === 'spawn_error') {
        console.error(
          `Workspace resolution could not be run. Run it manually:\n  ${r.command}`,
        );
      } else {
        console.error(`Workspace resolution failed (exit code ${r.status}): ${r.command}`);
      }
      return 1;
    }
  }

  // 9. Print the success summary to stdout and succeed.
  console.log(
    `Switched to flavor '${args.flavor}': ${targetPaths.length} file(s) copied, ` +
      `${deletedCount} file(s) deleted, dependency removed: ${depRemoved ? 'yes' : 'no'}`,
  );
  return 0;
}

// ---------------------------------------------------------------------------
// CLI entry wiring (task 11)
//
// The ONLY place the real `repoRoot` is resolved from `import.meta.url`: the
// script lives at `<repoRoot>/scripts/switch-flavor.mjs`, so `repoRoot` is the
// parent of this file's directory (see design "Component Discovery"). Core
// functions never hardcode this — they receive `repoRoot` by injection.
//
// Direct-invocation detection keeps the module side-effect free when imported
// by the test suite: `main`/`process.exit` run only when this file is the
// process entry script (its own path matches the resolved `process.argv[1]`),
// never on `import`.
// ---------------------------------------------------------------------------

const modulePath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(modulePath), '..');

const invokedDirectly =
  process.argv[1] !== undefined && path.resolve(process.argv[1]) === modulePath;

if (invokedDirectly) {
  process.exit(main(process.argv, { repoRoot }));
}
