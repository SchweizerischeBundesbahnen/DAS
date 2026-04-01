import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test preload is starting after login and retrieving settings', (tester) async {
    await prepareAndStartApp(tester);

    // Navigate to preload page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_preload_title));

    final preloadStatusTitleFinder = find.text(l10n.w_preload_status_title);
    expect(preloadStatusTitleFinder, findsOneWidget);

    // Check Preload is Running
    await waitUntilExists(tester, find.text(l10n.w_preload_status_running));

    for (var i = 0; i < 10; i++) {
      // Check Preload is still Running
      await waitUntilExists(tester, find.text(l10n.w_preload_status_running));
      await Future.delayed(const Duration(seconds: 1));
    }
  });
}
