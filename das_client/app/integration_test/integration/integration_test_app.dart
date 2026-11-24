import 'dart:ui';

import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:app/di/scopes/sfera_mock_scope.dart';
import 'package:app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_chat/component.dart';

import '../app_test.dart';
import '../util/test_utils.dart';
import 'integration_test_di.dart';

class const IntegrationTestApp._() {
  static Future<void> start(WidgetTester tester, {VoidCallback? onBeforeRun}) async {
    // iOS workaround for enterText not working on some devices, if its the first element
    // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
    tester.testTextInput.register();

    // Suppress the startup microphone permission request so the native permission
    // dialog never surfaces and blocks unrelated tests. Tests that exercise voice
    // chat can re-enable it by resetting this flag.
    VoiceChatComponent.suppressMicrophonePermissionRequest = true;

    await IntegrationTestDI.init(); // registers flavor, mockScopes and scope handler

    final scopeHandler = IntegrationTestDI.get<ScopeHandler>();
    await scopeHandler.push<DASBaseScope>();
    await scopeHandler.push<SferaMockScope>();

    l10n = await deviceLocalizations();
    onBeforeRun?.call();

    runDasApp();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}
