#!/usr/bin/env node

// Assign a stable, collision-free 20-char alphanumeric traceability ID to every
// integration test across das_client, das_backend and das_admin_tool.
//
// The ID is inserted into the test title/description, before an existing
// "|tests:XX" tag and after the description. The trailing metadata is normalized
// to an identical, whitespace-free "|<ID>|tests:XX" shape across all projects:
//
//   das_client   testWidgets('desc|tests:42')       -> 'desc|<ID>|tests:42'
//   das_backend  @DisplayName("desc|tests:42")       -> "desc|<ID>|tests:42"
//   das_admin    test('desc | tests: 42, 43')        -> 'desc|<ID>|tests:42,43'
//
// A title without a "tests:" tag simply gets the ID appended. Titles that
// already carry an ID keep it but are still re-normalized, so the script is
// safe to re-run (a re-run produces no git diff, which is what the CI jobs assert).
//
// Usage:
//   node scripts/test_title_has_id_no_whitespace.mjs [target ...]
//
// target is one of: client, backend, admin. With no target, all are processed.

import {existsSync, readdirSync, readFileSync, statSync, writeFileSync} from 'node:fs';
import {join, relative, resolve} from 'node:path';
import {randomInt} from 'node:crypto';

const REPO_ROOT = resolve(import.meta.dirname, '..');

const ID_LENGTH = 20;
const ID_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const ID_SEGMENT_RE = new RegExp(`^[A-Za-z0-9]{${ID_LENGTH}}$`);

// A "|tests:XX" tag: a pipe (optionally padded with spaces) followed by "tests:".
const TESTS_TAG_RE = /(\s*\|\s*)tests:/;

// The pipe used to separate the description, ID and tests tag in the normalized form.
const SEP = '|';

const TARGETS = {
    client: {
        label: 'das_client',
        dir: join(REPO_ROOT, 'das_client', 'app', 'integration_test', 'test'),
        nameFilter: (name) => name.endsWith('.dart'),
        // testWidgets('desc') / testWidgets("desc"), possibly wrapped onto the next line.
        titleRe: /(testWidgets\(\s*)(['"])((?:(?!\2).)*)\2/gs,
    },
    backend: {
        label: 'das_backend',
        dir: join(REPO_ROOT, 'das_backend', 'src', 'test'),
        nameFilter: (name) => name.endsWith('IntegrationTest.java') || name.endsWith('ControllerTest.java'),
        // @DisplayName("desc")
        titleRe: /(@DisplayName\(\s*)(")((?:(?!\2).)*)\2/g,
    },
    admin: {
        label: 'das_admin_tool',
        dir: join(REPO_ROOT, 'das_admin_tool', 'e2e', 'tests'),
        nameFilter: (name) => name.endsWith('.spec.ts'),
        // test('desc'), including test.only/skip/fixme variants; skips test.describe blocks.
        titleRe: /(\btest(?:\.(?:only|skip|fixme))?\(\s*)(['"`])((?:(?!\2).)*)\2/gs,
    },
};

function collectFiles(dir, nameFilter) {
    if (!existsSync(dir)) return [];
    const files = [];
    for (const name of readdirSync(dir)) {
        const full = join(dir, name);
        if (statSync(full).isDirectory()) {
            files.push(...collectFiles(full, nameFilter));
        } else if (nameFilter(name)) {
            files.push(full);
        }
    }
    return files.sort();
}

function hasId(title) {
    return title.split('|').some((part) => ID_SEGMENT_RE.test(part.trim()));
}

function normalizeTitle(title) {
    return title
        .split('|')
        .map((part) => {
            const trimmed = part.trim();
            return /^tests:/.test(trimmed) ? trimmed.replace(/\s+/g, '') : trimmed;
        })
        .join(SEP);
}

function generateId() {
    return Array.from({length: ID_LENGTH}, () => ID_ALPHABET[randomInt(ID_ALPHABET.length)]).join('');
}

function insertId(title, id) {
    const match = TESTS_TAG_RE.exec(title);
    if (match) {
        // Insert "<sep><id>" right before the existing "<sep>tests:" tag, reusing
        // the surrounding project's delimiter style (e.g. "|" or " | ").
        const sep = match[1];
        return title.slice(0, match.index) + sep + id + title.slice(match.index);
    }
    return null;
}

function processTarget(target) {
    let changedFiles = 0;
    let changedTests = 0;

    for (const file of collectFiles(target.dir, target.nameFilter)) {
        const content = readFileSync(file, 'utf8');
        if (target.contentGate && !target.contentGate(content)) continue;

        const newContent = content.replace(target.titleRe, (match, prefix, quote, title) => {
            let newTitle = normalizeTitle(title);
            if (!hasId(newTitle)) {
                const id = generateId();
                newTitle = insertId(newTitle, id) ?? `${newTitle}${SEP}${id}`;
            }
            if (newTitle === title) return match;
            changedTests++;
            return `${prefix}${quote}${newTitle}${quote}`;
        });

        if (newContent !== content) {
            writeFileSync(file, newContent);
            changedFiles++;
            console.log(`  updated ${relative(REPO_ROOT, file)}`);
        }
    }

    console.log(`${target.label}: ${changedTests} test(s) updated across ${changedFiles} file(s).`);
}

function main() {
    const requested = process.argv.slice(2);
    const unknown = requested.filter((name) => !TARGETS[name]);
    if (unknown.length > 0) {
        console.error(`Unknown target(s): ${unknown.join(', ')}. Valid targets: ${Object.keys(TARGETS).join(', ')}.`);
        process.exit(1);
    }
    const names = requested.length > 0 ? requested : Object.keys(TARGETS);

    for (const name of names) processTarget(TARGETS[name]);
}

main();
