import 'package:app/pages/preload/widgets/preload_status_display.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../e2e/e2e_test_app.dart';
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
  });
}
