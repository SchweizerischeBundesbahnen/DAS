#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const appDir = path.resolve(__dirname, '..');
const integrationRootDir = path.join(appDir, 'integration_test');
const runnerTestsPath = path.join(appDir, 'ios', 'RunnerTests', 'RunnerTests.m');
const testNameMapPath = path.join(appDir, 'ios', 'RunnerTests', 'test_name_map.json');

function main() {
  const selectedFolder = parseSuiteFolderFromArgs(process.argv.slice(2));
  const integrationTestsDir = path.join(integrationRootDir, selectedFolder);

  if (!fs.existsSync(integrationTestsDir)) {
    throw new Error(`Integration test folder does not exist: ${integrationTestsDir}`);
  }

  const dartFiles = listDartFiles(integrationTestsDir).sort((left, right) => left.localeCompare(right));
  const collectedTests = dartFiles.flatMap((filePath) => {
    const source = fs.readFileSync(filePath, 'utf8');
    return extractTests(source).map((test) => ({
      ...test,
      filePath,
      relativeFilePath: path.relative(appDir, filePath).replaceAll(path.sep, '/'),
      // The integration_test plugin derives the Objective-C selector from the
      // FULL dart test description (group names + test name), so build it from
      // fullName, not the leaf name.
      selector: toObjCTestSelector(test.fullName),
    }));
  });

  if (collectedTests.length === 0) {
    throw new Error(`No integration tests found in ${integrationTestsDir}`);
  }

  validateUniqueSelectors(collectedTests);

  const output = injectTestNamesIntoTemplate(collectedTests);
  fs.writeFileSync(runnerTestsPath, output);

  const testNameMap = buildTestNameMap(collectedTests);
  fs.writeFileSync(testNameMapPath, JSON.stringify(testNameMap, null, 2));

  process.stdout.write(
    `Generated ${path.relative(appDir, runnerTestsPath)} and ${path.relative(appDir, testNameMapPath)} with ${collectedTests.length} test names from ${dartFiles.length} Dart files in integration_test/${selectedFolder}.\n`,
  );
}

function buildTestNameMap(collectedTests) {
  return Object.fromEntries(collectedTests.map((test) => [test.selector, test.name]));
}

function parseSuiteFolderFromArgs(args) {
  const defaultFolder = 'test';
  if (args.length === 0) {
    return defaultFolder;
  }

  if (args.includes('--help') || args.includes('-h')) {
    printHelpAndExit();
  }

  const value = readArgValue(args, '--suite') ?? readArgValue(args, '--folder') ?? args[0];
  const normalized = normalizeSuiteFolder(value);
  if (normalized == null) {
    throw new Error(
      `Unknown suite folder "${value}". Use "test" or "e2e_test" (alias for "e2e_tests").`,
    );
  }

  return normalized;
}

function readArgValue(args, optionName) {
  const withEqualsPrefix = `${optionName}=`;
  const withEquals = args.find((arg) => arg.startsWith(withEqualsPrefix));
  if (withEquals) {
    return withEquals.slice(withEqualsPrefix.length);
  }

  const optionIndex = args.indexOf(optionName);
  if (optionIndex >= 0 && optionIndex + 1 < args.length) {
    return args[optionIndex + 1];
  }

  return null;
}

function normalizeSuiteFolder(value) {
  const rawValue = (value ?? 'test').trim();
  if (rawValue === 'test') {
    return 'test';
  }

  if (rawValue === 'e2e_test' || rawValue === 'e2e_tests') {
    return 'e2e_tests';
  }

  return null;
}

function printHelpAndExit() {
  process.stdout.write(
    [
      'Usage:',
      '  node app/scripts/generate_runner_tests.js [--suite <test|e2e_test>]',
      '  node app/scripts/generate_runner_tests.js [test|e2e_test]',
      '',
      'Notes:',
      '  - e2e_test is an alias and maps to integration_test/e2e_tests',
      '  - default suite is test',
      '',
    ].join('\n'),
  );
  process.exit(0);
}

function listDartFiles(directoryPath) {
  const entries = fs.readdirSync(directoryPath, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(directoryPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...listDartFiles(fullPath));
      continue;
    }

    if (entry.isFile() && entry.name.endsWith('.dart')) {
      files.push(fullPath);
    }
  }

  return files;
}

function extractTests(source) {
  const tests = [];
  walkRange(source, 0, source.length, [], tests);
  return tests;
}

function walkRange(source, start, end, groupStack, tests) {
  let index = start;

  while (index < end) {
    index = skipSpaceAndComments(source, index, end);
    if (index >= end) {
      return;
    }

    if (isIdentifierAt(source, index, 'group')) {
      const parsedGroup = parseNamedCall(source, index, 'group');
      if (parsedGroup && parsedGroup.bodyRange) {
        walkRange(source, parsedGroup.bodyRange.start, parsedGroup.bodyRange.end, [...groupStack, parsedGroup.name], tests);
        index = parsedGroup.end;
        continue;
      }
    }

    if (isIdentifierAt(source, index, 'testWidgets')) {
      const parsedTest = parseNamedCall(source, index, 'testWidgets');
      if (parsedTest) {
        if (!parsedTest.skipped) {
          tests.push({
            name: parsedTest.name,
            fullName: [...groupStack, parsedTest.name].join(' '),
          });
        }
        index = parsedTest.end;
        continue;
      }
    }

    if (isIdentifierAt(source, index, 'test')) {
      const parsedTest = parseNamedCall(source, index, 'test');
      if (parsedTest) {
        if (!parsedTest.skipped) {
          tests.push({
            name: parsedTest.name,
            fullName: [...groupStack, parsedTest.name].join(' '),
          });
        }
        index = parsedTest.end;
        continue;
      }
    }

    index += 1;
  }
}

function parseNamedCall(source, start, calleeName) {
  let index = start + calleeName.length;
  index = skipSpaceAndComments(source, index, source.length);
  if (source[index] !== '(') {
    return null;
  }

  const callEnd = findMatchingDelimiter(source, index, '(', ')');
  let cursor = skipSpaceAndComments(source, index + 1, callEnd);
  const nameString = readStringLiteral(source, cursor);
  if (!nameString) {
    return null;
  }

  const result = {
    name: nameString.value,
    end: callEnd + 1,
    skipped: hasSkipTrue(source, nameString.end, callEnd),
  };

  if (calleeName === 'group') {
    const bodyStart = findClosureBodyStart(source, nameString.end, callEnd);
    if (bodyStart != null) {
      const bodyEnd = findMatchingDelimiter(source, bodyStart, '{', '}');
      result.bodyRange = {
        start: bodyStart + 1,
        end: bodyEnd,
      };
    }
  }

  return result;
}

function hasSkipTrue(source, start, end) {
  let index = start;

  while (index < end) {
    index = skipSpaceAndComments(source, index, end);
    if (index >= end) {
      break;
    }

    if (isIdentifierAt(source, index, 'skip')) {
      let cursor = skipSpaceAndComments(source, index + 4, end);
      if (source[cursor] === ':') {
        cursor = skipSpaceAndComments(source, cursor + 1, end);
        if (isIdentifierAt(source, cursor, 'true')) {
          return true;
        }
      }
    }

    // Skip over strings so we don't match 'skip' inside string content
    if (source[index] === '\'' || source[index] === '"') {
      index = readStringLiteral(source, index).end;
      continue;
    }

    // Skip over nested parens/brackets so we don't match inside closures
    if (source[index] === '(') {
      index = findMatchingDelimiter(source, index, '(', ')') + 1;
      continue;
    }

    if (source[index] === '[') {
      index = findMatchingDelimiter(source, index, '[', ']') + 1;
      continue;
    }

    if (source[index] === '{') {
      index = findMatchingDelimiter(source, index, '{', '}') + 1;
      continue;
    }

    index += 1;
  }

  return false;
}

function findClosureBodyStart(source, start, end) {
  let index = start;

  while (index < end) {
    index = skipSpaceAndComments(source, index, end);
    if (index >= end) {
      return null;
    }

    const char = source[index];
    if (char === '{') {
      return index;
    }

    if (char === '\'' || char === '"') {
      index = readStringLiteral(source, index).end;
      continue;
    }

    if (char === '(') {
      index = findMatchingDelimiter(source, index, '(', ')') + 1;
      continue;
    }

    if (char === '[') {
      index = findMatchingDelimiter(source, index, '[', ']') + 1;
      continue;
    }

    index += 1;
  }

  return null;
}

function findMatchingDelimiter(source, start, openChar, closeChar) {
  let depth = 0;
  let index = start;

  while (index < source.length) {
    const char = source[index];

    if (char === '\'' || char === '"') {
      index = readStringLiteral(source, index).end;
      continue;
    }

    if (char === '/' && source[index + 1] === '/') {
      index = skipLineComment(source, index + 2);
      continue;
    }

    if (char === '/' && source[index + 1] === '*') {
      index = skipBlockComment(source, index + 2);
      continue;
    }

    if (char === openChar) {
      depth += 1;
    } else if (char === closeChar) {
      depth -= 1;
      if (depth === 0) {
        return index;
      }
    }

    index += 1;
  }

  throw new Error(`Unmatched delimiter ${openChar} in source.`);
}

function readStringLiteral(source, start) {
  const quote = source[start];
  if (quote !== '\'' && quote !== '"') {
    return null;
  }

  let index = start + 1;
  let value = '';

  while (index < source.length) {
    const char = source[index];
    if (char === '\\') {
      value += source.slice(index, index + 2);
      index += 2;
      continue;
    }

    if (char === quote) {
      return {
        value,
        end: index + 1,
      };
    }

    value += char;
    index += 1;
  }

  throw new Error('Unterminated string literal in Dart file.');
}

function skipSpaceAndComments(source, start, end) {
  let index = start;

  while (index < end) {
    const char = source[index];
    if (/\s/.test(char)) {
      index += 1;
      continue;
    }

    if (char === '/' && source[index + 1] === '/') {
      index = skipLineComment(source, index + 2);
      continue;
    }

    if (char === '/' && source[index + 1] === '*') {
      index = skipBlockComment(source, index + 2);
      continue;
    }

    break;
  }

  return index;
}

function skipLineComment(source, start) {
  let index = start;
  while (index < source.length && source[index] !== '\n') {
    index += 1;
  }
  return index;
}

function skipBlockComment(source, start) {
  let index = start;
  while (index < source.length) {
    if (source[index] === '*' && source[index + 1] === '/') {
      return index + 2;
    }
    index += 1;
  }
  throw new Error('Unterminated block comment in Dart file.');
}

function isIdentifierAt(source, index, identifier) {
  if (!source.startsWith(identifier, index)) {
    return false;
  }

  const previousChar = index > 0 ? source[index - 1] : '';
  const nextChar = source[index + identifier.length] ?? '';
  return !isIdentifierChar(previousChar) && !isIdentifierChar(nextChar);
}

function isIdentifierChar(char) {
  return /[A-Za-z0-9_]/.test(char);
}

// Reproduces exactly what the integration_test plugin computes natively in
// +[FLTIntegrationTestRunner testCaseNameFromDartTestName:], which is:
//
//   test<[[dartTestName localizedCapitalizedString] stripped of non-alphanumerics]>
//
// -[NSString localizedCapitalizedString] upper-cases the first letter of every
// "word" and lower-cases the rest. Foundation's word boundaries fall not only
// on whitespace/punctuation but also on letter<->digit transitions, so the
// first letter following a digit is capitalized too (e.g. "p7ydFbgh" becomes
// "P7Ydfbgh"). Non-alphanumeric characters are then removed entirely.
//
// The generated selector must match this byte-for-byte: RunnerTests.m looks the
// name up with an exact, case-sensitive set membership check, so any divergence
// turns the corresponding XCTest red.
function toObjCTestSelector(testName) {
  const characters = [...testName.normalize('NFC')];
  let result = '';
  let atWordStart = true;

  for (const character of characters) {
    if (isLetterCharacter(character)) {
      result += atWordStart ? character.toLocaleUpperCase() : character.toLocaleLowerCase();
      atWordStart = false;
      continue;
    }

    if (isDigitCharacter(character)) {
      result += character;
      // A letter directly after a digit starts a new word.
      atWordStart = true;
      continue;
    }

    // Any other (non-alphanumeric) character is dropped, and the next letter
    // begins a new word.
    atWordStart = true;
  }

  return `test${result}`;
}

function isLetterCharacter(character) {
  return /\p{L}/u.test(character);
}

function isDigitCharacter(character) {
  return /\p{N}/u.test(character);
}

function validateUniqueSelectors(collectedTests) {
  const selectors = new Map();

  for (const test of collectedTests) {
    const duplicate = selectors.get(test.selector);
    if (duplicate) {
      throw new Error(
        [
          `Duplicate XCTest selector generated: ${test.selector}`,
          `- ${duplicate.fullName} (${duplicate.relativeFilePath})`,
          `- ${test.fullName} (${test.relativeFilePath})`,
        ].join('\n'),
      );
    }

    selectors.set(test.selector, test);
  }
}

const GENERATED_MARKER = '//GENERATED CODE';

// Injects the collected test selector names into the hand-written RunnerTests.m
// template, replacing the body of the RunnerDartTestNames() array literal. The
// template itself (the lazy runner, testInvocations, etc.) is never touched.
//
// Everything between the `//GENERATED CODE` marker and the closing `];` of the
// `return @[ ... ];` statement is replaced on every run, so the generator is
// idempotent and can be re-run as the integration tests change.
function injectTestNamesIntoTemplate(collectedTests) {
  const template = fs.readFileSync(runnerTestsPath, 'utf8');

  const markerIndex = template.indexOf(GENERATED_MARKER);
  if (markerIndex < 0) {
    throw new Error(
      `Could not find "${GENERATED_MARKER}" marker in ${path.relative(appDir, runnerTestsPath)}. ` +
        'The generator injects the test name list at that marker.',
    );
  }

  const arrayEndIndex = template.indexOf('];', markerIndex);
  if (arrayEndIndex < 0) {
    throw new Error(
      `Could not find the closing "];" of the RunnerDartTestNames() array in ${path.relative(appDir, runnerTestsPath)}.`,
    );
  }

  // Preserve the indentation that precedes the marker so the generated entries
  // and the closing bracket line up with the surrounding array literal.
  const markerLineStart = template.lastIndexOf('\n', markerIndex) + 1;
  const markerIndent = template.slice(markerLineStart, markerIndex);
  const closingLineStart = template.lastIndexOf('\n', arrayEndIndex) + 1;
  const closingIndent = template.slice(closingLineStart, arrayEndIndex);

  const entries = collectedTests
    .map((test) => `${markerIndent}@"${test.selector}", // ${test.relativeFilePath}`)
    .join('\n');

  const generatedBlock = `${GENERATED_MARKER}\n${entries}\n${closingIndent}`;

  return template.slice(0, markerIndex) + generatedBlock + template.slice(arrayEndIndex);
}

main();

