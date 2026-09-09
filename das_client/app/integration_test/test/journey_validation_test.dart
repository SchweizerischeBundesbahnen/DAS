import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/widgets/login_button.dart';
import 'package:auth/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../auth/integration_test_authenticator.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
void main() {
  group('journey validation tests', () {
    testWidgets(
      'journeyValidation_whenActivated_thenAllowsMultipleBrakeSeriesSelectionAndDisplays|X0mynzY28I2IJmP07sSb|tests:2734',
      (tester) async {
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

        // drag bottom sheet
        final title = find.text(l10n.p_login_bottom_sheet_title);
        await tester.drag(title, Offset(0, -150));
        await tester.pumpAndSettle();

        // toggle validation mode on
        final validationModeToggle = find.ancestor(
          of: find.text(l10n.p_login_validation_mode),
          matching: find.byType(SBBSwitchListItem),
        );
        await tapElement(tester, validationModeToggle);

        // do not connect to TMS VAD
        final tmsConnectionToggle = find.ancestor(
          of: find.text(l10n.p_login_connect_to_tms),
          matching: find.byType(SBBSwitchListItem),
        );
        await tapElement(tester, tmsConnectionToggle);

        // login again
        testAuthenticator.isAuthenticated = true;
        await tapElement(tester, find.byType(LoginButton));

        await waitUntilExists(tester, find.byType(JourneySelectionPage));

        await loadJourney(tester, trainNumber: 'T5');

        // Open brake series bottom sheet
        await tapElement(tester, find.byKey(JourneyTable.brakeSeriesHeaderKey));

        // select two
        await tapElement(tester, find.text('R150'));
        await tapElement(tester, find.text('R105'));

        // confirm
        await tapElement(tester, find.text(l10n.c_button_confirm));

        await tester.pumpAndSettle();

        // find three in header
        final brakeSeriesHeaderCell = find.byKey(JourneyTable.brakeSeriesHeaderKey);
        expect(find.descendant(of: brakeSeriesHeaderCell, matching: find.text('R115')), findsOneWidget);
        expect(find.descendant(of: brakeSeriesHeaderCell, matching: find.text('R150')), findsOneWidget);
        expect(find.descendant(of: brakeSeriesHeaderCell, matching: find.text('R105')), findsOneWidget);
      },
    );
  });
}
