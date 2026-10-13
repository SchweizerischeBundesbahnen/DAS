@import XCTest;
@import integration_test;
@import ObjectiveC.runtime;

// One entry per Flutter test. Filled by app/scripts/generate_runner_tests.mjs
static NSArray<NSString *> *RunnerDartTestNames(void) {
  return @[
      //GENERATED CODE
  ];
}

static NSMutableDictionary<NSString *, NSString *> *RunnerFailures;
static NSMutableSet<NSString *> *RunnerSuccesses;
static BOOL RunnerDidRun = NO;

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests

// Runs the Flutter suite once, lazily, from inside the first test that executes.
+ (void)ensureIntegrationTestsExecuted {
  @synchronized(self) {
    if (RunnerDidRun) {
      return;
    }
    RunnerDidRun = YES;
    RunnerFailures = [NSMutableDictionary new];
    RunnerSuccesses = [NSMutableSet new];
    FLTIntegrationTestRunner *runner = [[FLTIntegrationTestRunner alloc] init];
    [runner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
      NSString *name = NSStringFromSelector(testSelector);
      if (success) {
        [RunnerSuccesses addObject:[name lowercaseString]];
      } else {
        RunnerFailures[[name lowercaseString]] = failureMessage ?: @"(no message)";
      }
    }];
  }
}

// Adds one XCTest method per Flutter test at runtime. Nothing runs here, so the
// Xcode construction-phase watchdog is not involved, and BrowserStack sees one method.
+ (NSArray<NSInvocation *> *)testInvocations {
  NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
  for (NSString *name in RunnerDartTestNames()) {
    SEL selector = NSSelectorFromString(name);
    IMP implementation = imp_implementationWithBlock(^(XCTestCase *testCase) {
      [RunnerTests ensureIntegrationTestsExecuted];
      if (![RunnerSuccesses containsObject:[name lowercaseString]]) {
        NSString *message = RunnerFailures[[name lowercaseString]] ?: @"not recorded";
        XCTIssue *issue = [[XCTIssue alloc] initWithType:XCTIssueTypeAssertionFailure
                                      compactDescription:[NSString stringWithFormat:@"%@: %@", name, message]];
        [testCase recordIssue:issue];
      }
    });
    class_addMethod(self, selector, implementation, "v@:");
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    [invocations addObject:invocation];
  }
  return invocations;
}

@end
