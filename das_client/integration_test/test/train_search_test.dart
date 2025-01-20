import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train search screen tests', () {
    testWidgets('test default values', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);
    });

    testWidgets('test selecting ru values', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_ru_sbb_p));

      expect(find.text(l10n.c_ru_sbb_c), findsOneWidget);
      expect(find.text(l10n.c_ru_bls_p), findsOneWidget);
      expect(find.text(l10n.c_ru_bls_c), findsOneWidget);
      expect(find.text(l10n.c_ru_sob), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_ru_sob));

      expect(find.text(l10n.c_ru_sob), findsOneWidget);
      expect(find.text(l10n.c_ru_sbb_p), findsNothing);
    });

    testWidgets('test load button disabled when validation fails', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);
    });

    testWidgets('test can select yesterday', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      final today = DateTime.now();
      final yesterday = today.add(Duration(days: -1));

      final todayDateTextFinder = find.text(Format.date(today));
      final yesterdayDateTextFinder = find.text(Format.date(yesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(yesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder);

      final sbbDatePickerFinder = find.byWidgetPredicate((widget) => widget is SBBDatePicker);
      final yesterdayFinder = find.descendant(
          of: sbbDatePickerFinder,
          matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == '${(yesterday.day)}.'));
      await tapElement(tester, yesterdayFinder);

      // tap outside dialog
      await tester.tapAt(Offset(200, 200));
      await tester.pumpAndSettle();

      expect(todayDateTextFinder, findsNothing);
      expect(yesterdayDateTextFinder, findsOneWidget);
      final warningMessage = find.text(l10n.p_train_selection_date_not_today_warning);
      expect(warningMessage, findsOneWidget);

    });

    testWidgets('test can not select day before yesterday', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      final today = DateTime.now();
      final yesterday = today.add(Duration(days: -1));
      final dayBeforeYesterday = today.add(Duration(days: -2));

      final todayDateTextFinder = find.text(Format.date(today));
      final yesterdayDateTextFinder = find.text(Format.date(yesterday));
      final dayBeforeYesterdayDateTextFinder = find.text(Format.date(dayBeforeYesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(yesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder);

      final sbbDatePickerFinder = find.byWidgetPredicate((widget) => widget is SBBDatePicker);
      final yesterdayFinder = find.descendant(
          of: sbbDatePickerFinder,
          matching:
              find.byWidgetPredicate((widget) => widget is Text && widget.data == '${(dayBeforeYesterday.day)}.'));
      await tapElement(tester, yesterdayFinder);

      // tap outside dialog
      await tester.tapAt(Offset(200, 200));
      await tester.pumpAndSettle();

      expect(todayDateTextFinder, findsNothing);
      expect(yesterdayDateTextFinder, findsOneWidget);
      final warningMessage = find.text(l10n.p_train_selection_date_not_today_warning);
      expect(warningMessage, findsOneWidget);
      expect(dayBeforeYesterdayDateTextFinder, findsNothing);
    });

    testWidgets('test error if JP unavailable', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '1234');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.text('${l10n.c_error_code}: ${ErrorCode.sferaJpUnavailable.code}'), findsOneWidget);
      expect(find.text(l10n.c_error_sfera_jp_unavailable), findsOneWidget);
    });
  });
}
