import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:settings/component.dart';

import '../app_test.dart';
import '../mocks/mock_settings_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('app expiration test', () {
    testWidgets('appExpiration_whenExpiresSoon_thenShowsDismissibleDialogOnce', (tester) async {
      await IntegrationTestApp.start(
        tester,
        onBeforeRun: () {
          final expiresVerySoon = AppVersionExpiration(expired: false, expiryDate: DateTime(2500));
          (DI.get<SettingsRepository>() as MockSettingsRepository).appVersionExpiration = expiresVerySoon;
        },
      );

      // dialog displayed and dismissed
      expect(find.text(l10n.w_app_expires_soon_dialog_title), findsOne);
      await tapElement(tester, find.byType(SBBTertiaryButtonSmall));
      expect(find.text(l10n.w_app_expires_soon_dialog_title), findsNothing);

      // open journey
      await loadJourney(tester, trainNumber: 'T9999M');

      // close journey
      await stopAutomaticAdvancement(tester);
      await tapElement(tester, find.byKey(JourneyPage.disconnectButtonKey));

      // dialog is not displayed
      expect(find.text(l10n.w_app_expires_soon_dialog_title), findsNothing);

      await disconnect(tester);
    });

    testWidgets('appExpiration_whenExpired_thenShowsNonDismissibleDialog', (
      tester,
    ) async {
      await IntegrationTestApp.start(
        tester,
        onBeforeRun: () {
          final expired = AppVersionExpiration(expired: true);
          (DI.get<SettingsRepository>() as MockSettingsRepository).appVersionExpiration = expired;
        },
      );

      expect(find.text(l10n.w_app_expired_dialog_title), findsOne);

      expect(find.byType(SBBTertiaryButtonSmall), findsNothing);

      await disconnect(tester);
    });
  });
}
