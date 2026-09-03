import 'package:app/pages/diagnostic/widgets/preload_status_display.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_page.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../e2e/e2e_test_app.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('preload_whenStartedAfterLogin_thenRetrievesFiles', (tester) async {
    await E2ETestApp.start(tester);

    // Navigate to diagnostic page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_diagnostic_title));

    final preloadStatusTitleFinder = find.text(l10n.w_preload_status_title);
    expect(preloadStatusTitleFinder, findsOneWidget);

    // Check Preload is Running
    await waitUntilExists(tester, find.text(l10n.w_preload_status_running));

    // We do not display downloaded segment when no data has yet been loaded
    await waitUntilExists(tester, find.byKey(PreloadStatusDisplay.downloadedSegmentKey));

    // Wait until all files preloaded so test fails not afterwards from Isolates and file operations ON EMULATOR
    // TODO: https://github.com/SchweizerischeBundesbahnen/DAS/issues/2752
    // await waitUntilNotExists(tester, find.byKey(PreloadStatusDisplay.initialSegmentKey), maxWaitSeconds: 480);
  });

  testWidgets('loadJourney_whenLoadsJourneyFromSferaMock_thenOpensJourneyTable', (tester) async {
    await E2ETestApp.start(tester);

    await loadJourney(
      tester,
      trainNumber: 'T9999',
      company: Company(code: '1285', shortName: 'SBBP'),
    );

    await disconnect(tester);
  });

  /// Note that this test relies on an entry in the DEV DB which will never be cleaned up by setting the operational day
  /// to a distant future.
  testWidgets('loadJourney_whenLoadsT12_thenShouldOpenBrakeLoadSlip', (tester) async {
    await E2ETestApp.start(tester);

    await loadJourney(
      tester,
      trainNumber: 'T12',
      company: Company(code: '2185', shortName: 'SBBCH'),
    );

    await openBrakeSlipPage(tester);
    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);

    await disconnect(tester);
  });

  // TODO: skip test for now since receiving Sfera Error 51 for any journey request after handshake succeeds (some validation going on)
  testWidgets('loadJourney_whenLoadsJourneyFromTmsVAD_thenOpensJourneyTable', skip: true, (tester) async {
    await E2ETestApp.start(tester, useTms: true);

    await loadJourney(
      tester,
      trainNumber: '18222',
      company: Company(code: '1285', shortName: 'SBBP'),
    );

    await disconnect(tester);
  });
}
