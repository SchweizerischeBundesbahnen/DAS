#!/usr/bin/env node
/**
 * Synchronizes @DisplayName annotations with test method names.
 *
 * - Adds @DisplayName("methodName") to @Test methods that don't have one yet.
 * - Updates the method name part in existing @DisplayName annotations if the method was renamed,
 *   while preserving the traceability ID and story IDs (e.g. "methodName|<ID>|tests:<ID>,<ID>").
 *
 * Only targets *ControllerTest.java and *IntegrationTest.java files.
 *
 * Usage:
 *   node scripts/java_test_display_names.mjs [test-root-dir]
 *
 * Default: das_backend/src/test
 */
import {readdirSync, readFileSync, writeFileSync} from 'fs';
import {join, relative} from 'path';

const ROOT = process.argv[2] || 'das_backend/src/test';
const DISPLAY_NAME_RE = /^(\s*@DisplayName\(")([^|]*)(\|[A-Za-z0-9]{20})?(\|tests:)([^"]*)("\).*)$/;

function findJavaFiles(dir) {
    const results = [];
    for (const entry of readdirSync(dir, {withFileTypes: true})) {
        const path = join(dir, entry.name);
        if (entry.isDirectory()) {
            results.push(...findJavaFiles(path));
        } else if (entry.name.endsWith('IntegrationTest.java') || entry.name.endsWith('ControllerTest.java')) {
            results.push(path);
        }
    }
    return results;
}

function processFile(content) {
    const lines = content.split('\n');
    const result = [];
    let synced = 0;
    let initialized = 0;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const methodMatch = line.match(/^(\s*)void\s+(\w+)\s*\(/);
        if (!methodMatch) {
            result.push(line);
            continue;
        }

        const [, indent, methodName] = methodMatch;

        // Look back through annotation block to find @Test and @DisplayName
        let hasTest = false;
        let displayNameIdx = -1;
        for (let j = i - 1; j >= 0; j--) {
            const prev = lines[j].trim();
            if (prev === '' || (!prev.startsWith('@') && !prev.startsWith('/') && !prev.startsWith('*'))) break;
            if (prev.startsWith('@Test')) hasTest = true;
            if (prev.startsWith('@DisplayName')) displayNameIdx = j;
        }

        if (!hasTest) {
            result.push(line);
            continue;
        }

        if (displayNameIdx >= 0) {
            const dnLine = result[displayNameIdx] || lines[displayNameIdx];
            const m = dnLine.match(DISPLAY_NAME_RE);
            if (m && m[2] !== methodName) {
                result[displayNameIdx] = `${m[1]}${methodName}${m[3] || ''}${m[4]}${m[5]}${m[6]}`;
                synced++;
            }
        } else {
            result.push(`${indent}@DisplayName("${methodName}|tests:")`);
            initialized++;
        }

        result.push(line);
    }

    return {output: result.join('\n'), synced, initialized};
}

let totalSynced = 0;
let totalInitialized = 0;

for (const file of findJavaFiles(ROOT).sort()) {
    const original = readFileSync(file, 'utf8');
    const {output, synced, initialized} = processFile(original);
    if (output === original) continue;

    writeFileSync(file, output);
    totalSynced += synced;
    totalInitialized += initialized;
    const parts = [];
    if (synced > 0) parts.push(`${synced} synced`);
    if (initialized > 0) parts.push(`${initialized} initialized`);
    console.log(`  ${relative(process.cwd(), file)}: ${parts.join(', ')}`);
}

console.log(`\nDone. Synced ${totalSynced}, initialized ${totalInitialized}.`);
