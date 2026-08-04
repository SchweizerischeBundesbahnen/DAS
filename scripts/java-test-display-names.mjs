#!/usr/bin/env node
/**
 * Synchronizes @DisplayName annotations with test method names.
 *
 * - Adds @DisplayName("methodName|tests:") to @Test methods that don't have one yet.
 * - Updates the method name part in existing @DisplayName("...|tests:...") if the method was renamed.
 *
 * Only targets *ControllerTest.java and *IntegrationTest.java files.
 *
 * Usage:
 *   node scripts/sync-display-names.mjs [test-root-dir]
 *
 * Default: das_backend/src/test
 */
import {readdirSync, readFileSync, writeFileSync} from 'fs';
import {join, relative} from 'path';

const ROOT = process.argv[2] || 'das_backend/src/test';

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

        // Detect method declaration: "  void methodName(...)"
        const methodMatch = line.match(/^(\s*)void\s+(\w+)\s*\(/);
        if (!methodMatch) {
            result.push(line);
            continue;
        }

        const indent = methodMatch[1];
        const methodName = methodMatch[2];

        // Look back to find annotation block
        let hasTest = false;
        let hasDisplayName = false;
        let displayNameLineIdx = -1;

        for (let j = i - 1; j >= 0; j--) {
            const prevLine = lines[j].trim();
            if (prevLine === '' || (!prevLine.startsWith('@') && !prevLine.startsWith('/') && !prevLine.startsWith('*'))) break;
            if (prevLine.startsWith('@Test')) hasTest = true;
            if (prevLine.startsWith('@DisplayName')) {
                hasDisplayName = true;
                displayNameLineIdx = j;
            }
        }

        if (!hasTest) {
            result.push(line);
            continue;
        }

        if (hasDisplayName && displayNameLineIdx >= 0) {
            // Sync: update method name in existing @DisplayName("...|tests:...")
            const dnLine = result[displayNameLineIdx] || lines[displayNameLineIdx];
            const dnMatch = dnLine.match(/^(\s*@DisplayName\(")(.*)(\|tests:)([^"]*)("\).*)$/);
            if (dnMatch && dnMatch[2] !== methodName) {
                result[displayNameLineIdx] = `${dnMatch[1]}${methodName}${dnMatch[3]}${dnMatch[4]}${dnMatch[5]}`;
                synced++;
            }
        } else {
            // Initialize: add @DisplayName("methodName|tests:") before the method
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

    if (synced > 0 || initialized > 0) {
        writeFileSync(file, output);
        totalSynced += synced;
        totalInitialized += initialized;
        const parts = [];
        if (synced > 0) parts.push(`${synced} synced`);
        if (initialized > 0) parts.push(`${initialized} initialized`);
        console.log(`  ${relative(process.cwd(), file)}: ${parts.join(', ')}`);
    }
}

console.log(`\nDone. Synced ${totalSynced}, initialized ${totalInitialized}.`);
