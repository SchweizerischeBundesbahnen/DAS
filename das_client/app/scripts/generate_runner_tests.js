#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const appDir = path.resolve(__dirname, '..');
const integrationTestsDir = path.join(appDir, 'integration_test', 'test');
const runnerTestsPath = path.join(appDir, 'ios', 'RunnerTests', 'RunnerTests.m');

function main() {
  const dartFiles = listDartFiles(integrationTestsDir).sort((left, right) => left.localeCompare(right));
  const collectedTests = dartFiles.flatMap((filePath) => {
    const source = fs.readFileSync(filePath, 'utf8');
    return extractTests(source).map((test) => ({
      ...test,
      filePath,
      relativeFilePath: path.relative(appDir, filePath).replaceAll(path.sep, '/'),
      selector: toObjCTestSelector(test.fullName),
    }));
  });

  if (collectedTests.length === 0) {
    throw new Error(`No integration tests found in ${integrationTestsDir}`);
  }

  validateUniqueSelectors(collectedTests);

  const output = buildRunnerTestsFile(collectedTests);
  fs.writeFileSync(runnerTestsPath, output);

  process.stdout.write(
    `Generated ${path.relative(appDir, runnerTestsPath)} with ${collectedTests.length} XCTest methods from ${dartFiles.length} Dart files.\n`,
  );
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
        tests.push({
          name: parsedTest.name,
          fullName: [...groupStack, parsedTest.name].join(' '),
        });
        index = parsedTest.end;
        continue;
      }
    }

    if (isIdentifierAt(source, index, 'test')) {
      const parsedTest = parseNamedCall(source, index, 'test');
      if (parsedTest) {
        tests.push({
          name: parsedTest.name,
          fullName: [...groupStack, parsedTest.name].join(' '),
        });
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

function toObjCTestSelector(testName) {
  const words = testName
    .normalize('NFKD')
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .map(capitalizeFirstCharacter)
    .join('');

  return `test${words}`;
}

function capitalizeFirstCharacter(value) {
  if (value.length === 0) {
    return value;
  }

  return value[0].toLocaleUpperCase() + value.slice(1);
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

function buildRunnerTestsFile(collectedTests) {
  const generatedMethods = collectedTests
    .map((test) => {
      return [
        `// ${test.relativeFilePath}`,
        `- (void)${test.selector} {`,
        `  [self assertRecordedSuccessWithPrefix:@"${test.selector}"];`,
        `}`,
      ].join('\n');
    })
    .join('\n\n');

  return `${buildFileHeader()}
static NSMutableArray<NSString *> *RunnerTestFailures;
static NSMutableSet<NSString *> *RunnerSuccessfulTests;
static NSDictionary<NSString *, UIImage *> *RunnerCapturedScreenshotsByName;
static BOOL RunnerIntegrationTestsDidRun = NO;
static BOOL RunnerScreenshotsAttached = NO;

@interface RunnerTests : XCTestCase
+ (NSArray<NSString *> *)recordedFailures;
+ (NSArray<NSString *> *)recordedSuccessfulTests;
@end

@implementation RunnerTests

+ (NSArray<NSString *> *)recordedFailures {
  return RunnerTestFailures.copy ?: @[];
}

+ (NSArray<NSString *> *)recordedSuccessfulTests {
  return RunnerSuccessfulTests.allObjects ?: @[];
}

- (void)ensureIntegrationTestsExecuted {
  @synchronized([RunnerTests class]) {
    if (RunnerIntegrationTestsDidRun) {
      [self attachCapturedScreenshotsIfNeeded];
      return;
    }

    RunnerIntegrationTestsDidRun = YES;
    RunnerTestFailures = [[NSMutableArray alloc] init];
    RunnerSuccessfulTests = [[NSMutableSet alloc] init];

    FLTIntegrationTestRunner *integrationTestRunner = [[FLTIntegrationTestRunner alloc] init];
    [integrationTestRunner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
      NSString *name = NSStringFromSelector(testSelector);
      if (success) {
        [RunnerSuccessfulTests addObject:name];
      } else {
        [RunnerTestFailures addObject:[NSString stringWithFormat:@"%@: %@", name, failureMessage ?: @"(no message)"]];
      }
    }];

    RunnerCapturedScreenshotsByName = integrationTestRunner.capturedScreenshotsByName ?: @{};
  }

  [self attachCapturedScreenshotsIfNeeded];
}

- (void)attachCapturedScreenshotsIfNeeded {
  @synchronized([RunnerTests class]) {
    if (RunnerScreenshotsAttached) {
      return;
    }

    RunnerScreenshotsAttached = YES;
    [RunnerCapturedScreenshotsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, UIImage *screenshot, BOOL *stop) {
      XCTAttachment *attachment = [XCTAttachment attachmentWithImage:screenshot];
      attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
      if (name != nil) {
        attachment.name = name;
      }
      [self addAttachment:attachment];
    }];
  }
}

- (NSString *)recordedFailureWithPrefix:(NSString *)testNamePrefix {
  [self ensureIntegrationTestsExecuted];

  NSString *expectedPrefix = [NSString stringWithFormat:@"%@:", testNamePrefix];
  for (NSString *failure in RunnerTestFailures ?: @[]) {
    if ([failure hasPrefix:expectedPrefix]) {
      return failure;
    }
  }

  return nil;
}

- (BOOL)hasRecordedSuccessWithPrefix:(NSString *)testNamePrefix {
  [self ensureIntegrationTestsExecuted];

  for (NSString *successfulTestName in RunnerSuccessfulTests ?: [NSSet set]) {
    if ([successfulTestName hasPrefix:testNamePrefix]) {
      return YES;
    }
  }

  return NO;
}

- (void)assertRecordedSuccessWithPrefix:(NSString *)testNamePrefix {
  if ([self hasRecordedSuccessWithPrefix:testNamePrefix]) {
    return;
  }

  NSString *failure = [self recordedFailureWithPrefix:testNamePrefix];
  if (failure != nil) {
    XCTFail(@"%@", failure);
    return;
  }

  NSArray<NSString *> *successfulTests = [[RunnerSuccessfulTests allObjects] sortedArrayUsingSelector:@selector(compare:)];
  XCTFail(@"Expected %@ in successful tests list, but it was not recorded. Successful tests:\\n%@",
          testNamePrefix,
          [successfulTests componentsJoinedByString:@"\\n"]);
}

// BEGIN GENERATED XCTESTS
${generatedMethods}
// END GENERATED XCTESTS

@end
`;
}

function buildFileHeader() {
  return `@import XCTest;
@import integration_test;
@import ObjectiveC.runtime;
@import UIKit;

// Generated by app/scripts/generate_runner_tests.js.
//
// This file creates one XCTest case per Flutter integration test found under
// app/integration_test/test. The Flutter test suite is executed lazily once and
// stores successful test selector names in RunnerSuccessfulTests.
// Each generated XCTest validates that its selector name appears in that list.
//
// The original motivation is to avoid the Xcode 15+ construction watchdog while
// still exposing individual XCTest results instead of a single aggregate test.`;
}

main();

