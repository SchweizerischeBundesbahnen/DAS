import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/flavor.dart';
import 'package:app/main.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../e2e_test_di.dart';
import '../util/test_utils.dart';
import 'e2e_authenticator_override_scope.dart';
import 'e2e_warnapp_override_scope.dart';

class E2ETestApp {
  const E2ETestApp._();

  static Future<void> start(WidgetTester tester, {AsyncCallback? onBeforeRun}) async {
    // iOS workaround for enterText not working on some devices, if its the first element
    // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
    tester.testTextInput.register();

    await E2ETestDI.init(); // registers flavor, scopes including overrides and scope handler

    final scopeHandler = DI.get<ScopeHandler>();
    await scopeHandler.push<DASBaseScope>();
    await scopeHandler.push<E2EWarnappOverrideScope>();
    await scopeHandler.push<SferaMockScope>();
    await scopeHandler.push<E2EAuthenticatorOverrideScope>();

    l10n = await deviceLocalizations();
    await onBeforeRun?.call();

    await _initMessaging();
    runDasApp();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}

Future<void> _initMessaging() async {
  final environment = Flavor.dev().customerOrientedDepartureEnvironment;
  await CustomerOrientedDepartureComponent.initializeMessaging(connectTo: environment);
}
