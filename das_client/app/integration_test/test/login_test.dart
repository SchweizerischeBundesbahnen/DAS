import 'package:app/di/di.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/widgets/login_button.dart';
import 'package:app/widgets/mqtt_broker_text.dart';
import 'package:auth/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../auth/integration_test_authenticator.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  group('login tests', () {
    testWidgets('login_whenLogoutDialogIsDismissed_thenIsStillLoggedIn', (tester) async {
      await IntegrationTestApp.start(tester);
      expect(find.byType(JourneySelectionPage), findsOne);

      // open logout dialog
      final logoutButton = find.byIcon(SBBIcons.exit_small);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      final logoutDialogTitle = find.text(l10n.w_logout_dialog_title);
      expect(logoutDialogTitle, findsOne);

      // cancel logout
      final logoutDialogCancelButtonLabel = find.text(l10n.w_logout_dialog_cancel_button_labelText);
      await tester.tap(logoutDialogCancelButtonLabel);
      await tester.pumpAndSettle();

      // still on selection page
      expect(find.byType(JourneySelectionPage), findsOne);
    });

    testWidgets('login_whenStartedDefault_thenIsConnectedToMockBroker', (tester) async {
      await IntegrationTestApp.start(tester);
      expect(find.byType(JourneySelectionPage), findsOne);

      await openDrawer(tester);
      expect(find.text(MqttBrokerText.mockText), findsOne);
    });

    testWidgets('login_whenLogout_thenDefaultSelectionIsTmsVadOnLoginPage', (tester) async {
      await IntegrationTestApp.start(tester);
      expect(find.byType(JourneySelectionPage), findsOne);

      // perform logout
      final logoutButton = find.byIcon(SBBIcons.exit_small);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      final logoutDialogTitle = find.text(l10n.w_logout_dialog_title);
      expect(logoutDialogTitle, findsOne);
      final testAuthenticator = DI.get<Authenticator>() as IntegrationTestAuthenticator;
      testAuthenticator.isAuthenticated = false;

      final logoutDialogConfirmButtonLabel = find.text(l10n.w_logout_dialog_confirm_button_labelText);
      await tester.tap(logoutDialogConfirmButtonLabel);

      await waitUntilExists(tester, find.byType(LoginPage));

      // enable connection to mock broker
      // drag bottom sheet
      final title = find.text(l10n.p_login_bottom_sheet_title);
      await tester.drag(title, Offset(0, -150));
      await tester.pumpAndSettle();

      // expect toggle to be set to true
      final tmsToggleListItem = find.ancestor(
        of: find.text(l10n.p_login_connect_to_tms),
        matching: find.byType(SBBSwitchListItemBoxed),
      );
      expect((tmsToggleListItem.evaluate().first.widget as SBBSwitchListItemBoxed).value, isTrue);
    });

    testWidgets('login_whenLogoutThenLogin_thenWillConnectToTmsVad', (tester) async {
      await IntegrationTestApp.start(tester);
      expect(find.byType(JourneySelectionPage), findsOne);

      // perform logout
      final logoutButton = find.byIcon(SBBIcons.exit_small);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      final logoutDialogTitle = find.text(l10n.w_logout_dialog_title);
      expect(logoutDialogTitle, findsOne);
      final logoutDialogConfirmButtonLabel = find.text(l10n.w_logout_dialog_confirm_button_labelText);
      await tester.tap(logoutDialogConfirmButtonLabel);

      await waitUntilExists(tester, find.byType(LoginPage));

      // login again
      final testAuthenticator = DI.get<Authenticator>() as IntegrationTestAuthenticator;
      testAuthenticator.isAuthenticated = true;
      await tapElement(tester, find.byType(LoginButton));
      await tester.pumpAndSettle();

      // check connects to TMS VAD
      await waitUntilExists(tester, find.byType(JourneySelectionPage));
      await openDrawer(tester);
      expect(find.text(MqttBrokerText.tmsVadText), findsOne);
    });

    testWidgets('login_whenLogoutThenLoginWithSferaMockToggled_thenWillConnectToSferaMock', (tester) async {
      await IntegrationTestApp.start(tester);
      expect(find.byType(JourneySelectionPage), findsOne);

      // perform logout
      final logoutButton = find.byIcon(SBBIcons.exit_small);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      final logoutDialogTitle = find.text(l10n.w_logout_dialog_title);
      expect(logoutDialogTitle, findsOne);
      final testAuthenticator = DI.get<Authenticator>() as IntegrationTestAuthenticator;
      testAuthenticator.isAuthenticated = false;

      final logoutDialogConfirmButtonLabel = find.text(l10n.w_logout_dialog_confirm_button_labelText);
      await tester.tap(logoutDialogConfirmButtonLabel);

      await waitUntilExists(tester, find.byType(LoginPage));

      testAuthenticator.isAuthenticated = true;
      await tapElement(tester, find.byType(LoginButton));

      await waitUntilExists(tester, find.byType(JourneySelectionPage));
      await openDrawer(tester);
      expect(find.text(MqttBrokerText.tmsVadText), findsOne);
    });
  });
}
