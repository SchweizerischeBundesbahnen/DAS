#!/usr/bin/env node
/**
 * Extract test results from Surefire XML reports.
 */
import {readdirSync, readFileSync, writeFileSync} from 'fs';
import {execSync} from 'child_process';
import {join} from 'path';

const SUREFIRE_DIR = process.argv[2] || 'das_backend/target/surefire-reports';
const OUTPUT_FILE = process.argv[3] || 'das_backend/target/test-report.json';

function getGitSha() {
    try {
        return execSync('git rev-parse HEAD', {encoding: 'utf8'}).trim();
    } catch {
        return 'unknown';
    }
}

const testcases = [];
const files = readdirSync(SUREFIRE_DIR).filter(f => f.startsWith('TEST-') && f.endsWith('.xml'));

for (const file of files.sort()) {
    const xml = readFileSync(join(SUREFIRE_DIR, file), 'utf8');

    // Match self-closing testcases: <testcase name="..." ... />
    const selfClosingRegex = /<testcase\s+([^>]*?)\/>/g;
    let match;
    while ((match = selfClosingRegex.exec(xml)) !== null) {
        const attrs = match[1];
        const nameMatch = attrs.match(/name="([^"]*)"/);
        if (!nameMatch) continue;
        const name = nameMatch[1];
        if (!name.includes('|tests:')) continue;
        testcases.push({name, status: 'passed'});
    }

    // Match testcases with body: <testcase name="..." ...>...</testcase>
    const withBodyRegex = /<testcase\s+([^>]*?)>([\s\S]*?)<\/testcase>/g;
    while ((match = withBodyRegex.exec(xml)) !== null) {
        const attrs = match[1];
        const body = match[2];
        const nameMatch = attrs.match(/name="([^"]*)"/);
        if (!nameMatch) continue;
        const name = nameMatch[1];
        if (!name.includes('|tests:')) continue;

        const hasFailure = /<failure[\s>]/.test(body) || /<error[\s>]/.test(body);
        const status = hasFailure ? 'failed' : 'passed';

        testcases.push({name, status});
    }
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
