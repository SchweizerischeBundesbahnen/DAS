import 'package:das_client/app/pages/profile/profile_page.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {
    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      // List of expected column headers
      final List<String> expectedHeaders = [
        l10n.p_train_journey_table_kilometre_label,
        l10n.p_train_journey_table_journey_information_label,
        l10n.p_train_journey_table_time_label,
        l10n.p_train_journey_table_advised_speed_label,
        l10n.p_train_journey_table_braked_weight_speed_label,
        l10n.p_train_journey_table_graduated_speed_label,
      ];

      // Check if each header is present in the widget tree
      for (final header in expectedHeaders) {
        expect(find.text(header), findsOneWidget);
      }
    });

    testWidgets('test scrolling to last train station', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check first train station
      expect(find.text('ZUE'), findsOneWidget);

      // Scroll to last train station
      await tester.dragUntilVisible(
          find.text('AAR'),
          find.byType(ListView),
          const Offset(0, -300)
      );
    });

    testWidgets('test fahrbild stays loaded after navigation', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      // check first train station
      expect(find.text('ZUE'), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // check first train station is still visible
      expect(find.text('ZUE'), findsOneWidget);
    });
  });
}

/// Verifies, that SBB is selected and loads train journey with [trainNumber]
Future<void> _loadTrainJourney(WidgetTester tester, {required String trainNumber}) async {
  // verify we have ru SBB selected.
  expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

  final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
  expect(trainNumberText, findsOneWidget);

  await enterText(tester, trainNumberText, trainNumber);

  // load train journey
  final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
  await tester.tap(primaryButton);

  // wait for train journey to load
  await tester.pumpAndSettle();
}
