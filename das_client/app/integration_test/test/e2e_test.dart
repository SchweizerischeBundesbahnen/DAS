import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_page.dart';
import 'package:app/pages/preload/widgets/preload_status_display.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../app_test.dart';
import '../e2e/e2e_authenticator_override_scope.dart';
import '../e2e/e2e_test_app.dart';
import '../util/e2e_test_utils.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('preload_whenStartedAfterLogin_thenRetrievesFiles', (tester) async {
    await E2ETestApp.start(tester);

    // Navigate to preload page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_preload_title));

    final preloadStatusTitleFinder = find.text(l10n.w_preload_status_title);
    expect(preloadStatusTitleFinder, findsOneWidget);

    // Check Preload is Running
    await waitUntilExists(tester, find.text(l10n.w_preload_status_running));

    // We do not display downloaded segment when no data has yet been loaded
    await waitUntilExists(tester, find.byKey(PreloadStatusDisplay.downloadedSegmentKey));

    // Wait until all files preloaded so test fails not afterwards from Isolates and file operations ON EMULATOR
    // TODO: maybe add possibility to interrupt preload gracefully - difficult with isolates though
    // await waitUntilNotExists(tester, find.byKey(PreloadStatusDisplay.initialSegmentKey), maxWaitSeconds: 480);
  });

  testWidgets('loadJourney_whenLoadsT9999_thenOpensJourneyTable', (tester) async {
    await E2ETestApp.start(tester);

    await loadJourney(tester, trainNumber: 'T9999', ru: .sbbP);
    await optionallyDismissBrightnessModalOnAndroid(tester);

    await disconnect(tester);
  });

  /// Note that this test relies on an entry in the DEV DB which will never be cleaned up by setting the operational day
  /// to a distant future.
  testWidgets('loadJourney_whenLoadsT12_thenShouldOpenBrakeLoadSlip', (tester) async {
    await E2ETestApp.start(tester);

    await loadJourney(tester, trainNumber: 'T12', ru: .sbbCH);
    await optionallyDismissBrightnessModalOnAndroid(tester);

    await openBrakeSlipPage(tester);
    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);

    await disconnect(tester);
  });

  /// TODO: connection to TMS VAD fails very unreliably - something to do with the scopes ?
  testWidgets('loadJourney_whenLoadsJourneyFromTmsVAD_thenOpensJourneyTable', skip: true, (tester) async {
    await E2ETestApp.start(
      tester,
      onBeforeRun: () async {
        final scopeHandler = DI.get<ScopeHandler>();
        await scopeHandler.pop<E2EAuthenticatorOverrideScope>();
        await scopeHandler.pop<SferaMockScope>();
        await scopeHandler.push<TmsScope>();
        await scopeHandler.push<E2EAuthenticatorOverrideScope>();
        await GetIt.I.allReady();
      },
    );

    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_preload_title));
    await openDrawer(tester);
    await tester.pumpAndSettle(Duration(milliseconds: 500));
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));
    await loadJourney(tester, trainNumber: '18222', ru: .sbbP);

    await disconnect(tester);
  });
}
