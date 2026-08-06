#!/usr/bin/env node
/**
 * Extract test results from Playwright JSON report.
 */
import {readFileSync, writeFileSync} from 'fs';
import {execSync} from 'child_process';

const INPUT_FILE = process.argv[2] || 'das_admin_tool/e2e/test-results/test-results.json';
const OUTPUT_FILE = process.argv[3] || 'das_admin_tool/e2e/test-results/test-report.json';

function getGitSha() {
    try {
        return execSync('git rev-parse HEAD', {encoding: 'utf8'}).trim();
    } catch {
        return 'unknown';
    }
}

function extractFromSuite(suite, testcases) {
    for (const spec of suite.specs ?? []) {
        const name = spec.title;
        if (!name.includes('|tests:')) continue;
        const status = spec.ok ? 'passed' : 'failed';
        testcases.push({name, status});
    }
    for (const child of suite.suites ?? []) {
        extractFromSuite(child, testcases);
    }
}

const report = JSON.parse(readFileSync(INPUT_FILE, 'utf8'));
const testcases = [];

for (const suite of report.suites ?? []) {
    extractFromSuite(suite, testcases);
}

const output = {
    id: getGitSha(),
    data: [
        {
            testcases,
        },
    ],
};

writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));
console.log(`Extracted ${testcases.length} tests -> ${OUTPUT_FILE}`);
