import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_chat/component.dart';

import '../app_test.dart';
import '../util/test_utils.dart';
import 'e2e_test_di.dart';

class const E2ETestApp._() {
  static Future<void> start(WidgetTester tester, {AsyncCallback? onBeforeRun, bool useTms = false}) async {
    // iOS workaround for enterText not working on some devices, if its the first element
    // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
    tester.testTextInput.register();

    // Suppress the startup microphone permission request so the native permission
    // dialog never surfaces and blocks unrelated tests. Tests that exercise voice
    // chat can re-enable it by resetting this flag.
    VoiceChatComponent.suppressMicrophonePermissionRequest = true;

    await E2ETestDI.init(); // registers flavor, scopes including overrides and scope handler

    final scopeHandler = DI.get<ScopeHandler>();
    await scopeHandler.push<DASBaseScope>();
    if (useTms) {
      await scopeHandler.push<TmsScope>();
    } else {
      await scopeHandler.push<SferaMockScope>();
    }

    l10n = await deviceLocalizations();
    await onBeforeRun?.call();

    runDasApp();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}
