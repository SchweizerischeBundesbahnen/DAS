import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:app/di/scopes/sfera_mock_scope.dart';
import 'package:app/flavor.dart';
import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../integration_test_di.dart';
import '../util/test_utils.dart';

class E2ETestApp {
  const E2ETestApp._();

  static Future<void> start(WidgetTester tester, {VoidCallback? onBeforeRun}) async {
    // iOS workaround for enterText not working on some devices, if its the first element
    // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
    tester.testTextInput.register();

    await IntegrationTestDI.init(Flavor.dev(), e2e: true); // registers flavor, mockScopes and scope handler

    final scopeHandler = IntegrationTestDI.get<ScopeHandler>();
    await scopeHandler.push<DASBaseScope>();
    await scopeHandler.push<SferaMockScope>();

    l10n = await deviceLocalizations();
    onBeforeRun?.call();

    runDasApp();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}
