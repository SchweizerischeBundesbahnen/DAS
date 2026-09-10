#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appDir = path.resolve(__dirname, '..');
const defaultTestNameMapPath = path.join(appDir, 'ios', 'RunnerTests', 'test_name_map.json');

function main() {
  const reportPath = process.argv[2];
  if (!reportPath) {
    throw new Error(
      'Usage: node app/scripts/rewrite_ios_test_report_names.mjs <reportPath> [testNameMapPath]',
    );
  }

  const testNameMapPath = process.argv[3] ?? defaultTestNameMapPath;

  const testNameMap = JSON.parse(fs.readFileSync(testNameMapPath, 'utf8'));
  const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));

  let replaced = 0;
  let unmatched = 0;

  for (const sessionEntry of report.sessions ?? []) {
    const testClasses = sessionEntry.session?.testcases?.data ?? [];
    for (const testClass of testClasses) {
      for (const testcase of testClass.testcases ?? []) {
        const readableName = testNameMap[testcase.name];
        if (readableName) {
          testcase.name = readableName;
          replaced += 1;
        } else {
          unmatched += 1;
          process.stderr.write(
            `::warning::No name mapping found for iOS test "${testcase.name}"; leaving it as-is.\n`,
          );
        }
      }
    }
  }

  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

  process.stdout.write(
    `Rewrote ${replaced} test name(s) in ${path.basename(reportPath)} using ${path.relative(appDir, testNameMapPath)} (${unmatched} unmatched).\n`,
  );
}

main();
