import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';

void main() {
  group('train journey table test', () {
    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);
      await tester.pump(const Duration(seconds: 1));

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816', companyCode: '1085');

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
      await tester.pump(const Duration(seconds: 1));

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816', companyCode: '1085');

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
  });
}

/// Fills out train selection fields with given [companyCode] and [trainNumber] and loads train journey
Future<void> _loadTrainJourney(WidgetTester tester, {required String companyCode, required String trainNumber}) async {
  final companyDescriptionTextField = find.ancestor(
    of: find.text(l10n.p_train_selection_company_description),
    matching: find.byType(SBBTextField),
  );
  await tester.enterText(companyDescriptionTextField, companyCode);

  final trainNumberTextField = find.ancestor(
    of: find.text(l10n.p_train_selection_trainnumber_description),
    matching: find.byType(SBBTextField),
  );
  await tester.enterText(trainNumberTextField, trainNumber);

  // load train journey
  final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
  await tester.tap(primaryButton);

  // wait for train journey to load
  await tester.pumpAndSettle(const Duration(seconds: 1));
}
