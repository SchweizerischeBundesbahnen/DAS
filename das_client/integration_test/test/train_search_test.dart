import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train search screen tests', () {

    testWidgets('test default values', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have evu SBB.
      expect(find.text(l10n.c_evu_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);
    });

    testWidgets('test selecting evu values', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have evu SBB.
      expect(find.text(l10n.c_evu_sbb_p), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_evu_sbb_p));

      await tester.pumpAndSettle();

      expect(find.text(l10n.c_evu_sbb_c), findsOneWidget);
      expect(find.text(l10n.c_evu_bls_p), findsOneWidget);
      expect(find.text(l10n.c_evu_bls_c), findsOneWidget);
      expect(find.text(l10n.c_evu_sob), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_evu_sob));

      await tester.pumpAndSettle();

      expect(find.text(l10n.c_evu_sob), findsOneWidget);
      expect(find.text(l10n.c_evu_sbb_p), findsNothing);
    });

    testWidgets('test load button disabled when validation fails', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have evu SBB.
      expect(find.text(l10n.c_evu_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      var trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await tester.enterText(trainNumberText, '');
      await tester.pump(Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // check that the primary button is disabled
      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);

    });

    testWidgets('test can select yesterday', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      final today = DateTime.now();
      final yesterday = today.add(Duration(days: -1));

      var todayDateTextFinder = find.text(Format.date(today));
      var yesterdayDateTextFinder = find.text(Format.date(yesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(yesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder);

      await tester.pumpAndSettle();

      final sbbDatePickerFinder = find.byWidgetPredicate((widget) => widget is SBBDatePicker);
      final yesterdayFinder = find.descendant(
          of: sbbDatePickerFinder,
          matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == '${(yesterday.day)}.'));
      await tapAt(tester, yesterdayFinder);

      await tester.pumpAndSettle();

      // tap outside dialog
      await tester.tapAt(Offset(200, 200));

      await tester.pumpAndSettle();

      expect(todayDateTextFinder, findsNothing);
      expect(yesterdayDateTextFinder, findsOneWidget);

    });

    testWidgets('test can not select day before yesterday', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      final today = DateTime.now();
      final yesterday = today.add(Duration(days: -1));
      final dayBeforeYesterday = today.add(Duration(days: -2));

      var todayDateTextFinder = find.text(Format.date(today));
      var yesterdayDateTextFinder = find.text(Format.date(yesterday));
      var dayBeforeYesterdayDateTextFinder = find.text(Format.date(dayBeforeYesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(yesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder);

      await tester.pumpAndSettle();

      final sbbDatePickerFinder = find.byWidgetPredicate((widget) => widget is SBBDatePicker);
      final yesterdayFinder = find.descendant(
          of: sbbDatePickerFinder,
          matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == '${(dayBeforeYesterday.day)}.'));
      await tapAt(tester, yesterdayFinder);

      await tester.pumpAndSettle();

      // tap outside dialog
      await tester.tapAt(Offset(200, 200));

      await tester.pumpAndSettle();

      expect(todayDateTextFinder, findsNothing);
      expect(yesterdayDateTextFinder, findsOneWidget);
      expect(dayBeforeYesterdayDateTextFinder, findsNothing);
    });

    testWidgets('test error if JP unavailable', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have evu SBB.
      expect(find.text(l10n.c_evu_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      var trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await tester.enterText(trainNumberText, '1234');
      await tester.pump(Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // check that the primary button is disabled
      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tester.tap(primaryButton);

      await tester.pumpAndSettle();

      expect(find.text(ErrorCode.sferaJpUnavailable.toString()), findsOneWidget);

    });

  });
}
