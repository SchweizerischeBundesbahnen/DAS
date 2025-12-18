import 'package:app/pages/journey/selection/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train search screen tests', () {
    testWidgets('test default values', (tester) async {
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);
    });

    testWidgets('test selecting ru values', (tester) async {
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_ru_sbb_p), warnIfMissed: false);

      // Verify modal is opened
      final modal = find.byKey(SelectRailwayUndertakingModal.modalKey);
      expect(modal, findsOneWidget);

      expect(find.text(l10n.c_ru_sbb_c), findsOneWidget);
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_bls_p)), findsOneWidget);
      expect(find.text(l10n.c_ru_bls_c), findsOneWidget);
      final sobI = find.text(l10n.c_ru_sob_infra);
      await tester.dragUntilVisible(sobI, modal, const Offset(0, -50));
      expect(sobI, findsOneWidget);
      await tapElement(tester, sobI, warnIfMissed: false);
      expect(sobI, findsOneWidget);
    });

    testWidgets('test filter ru values', (tester) async {
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      await tapElement(tester, find.text(l10n.c_ru_sbb_p), warnIfMissed: false);

      // Verify modal is opened
      final modal = find.byKey(SelectRailwayUndertakingModal.modalKey);
      expect(modal, findsOneWidget);

      // Enter filter 'SO'
      final filterField = find.byKey(SelectRailwayUndertakingModal.filterFieldKey);
      expect(filterField, findsOneWidget);
      await enterText(tester, filterField, 'SO');
      await tester.pumpAndSettle();

      // Verify results are filtered
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_sbb_p)), findsNothing);
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_bls_p)), findsNothing);
      expect(find.text(l10n.c_ru_sob_infra), findsOneWidget);
    });

    testWidgets('test load button disabled when validation fails', (tester) async {
      await prepareAndStartApp(tester);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      // Verify that no train number is there
      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);
    });

    testWidgets('test can select yesterday', (tester) async {
      await prepareAndStartApp(tester);

      final today = DateTime.now();
      final yesterday = today.add(Duration(days: -1));

      final todayDateTextFinder = find.text(Format.date(today));
      final yesterdayDateTextFinder = find.text(Format.date(yesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(yesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder, warnIfMissed: false);

      final datePicker = find.byKey(JourneyDatePicker.datePickerKey);

      // finds localized 'Today'
      final todayFinder = find.descendant(
        of: datePicker,
        matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == l10n.c_today),
      );
      expect(todayFinder, findsOne);

      // find yesterday date and select it
      final yesterdayFinder = find.descendant(
        of: datePicker,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == Format.dateWithTextMonth(yesterday, appLocale()),
        ),
      );
      await tapElement(tester, yesterdayFinder, warnIfMissed: false);

      await tester.pumpAndSettle();

      // expect yesterday is selected with warning
      expect(todayDateTextFinder, findsNothing);
      expect(yesterdayDateTextFinder, findsOneWidget);
      final warningMessage = find.text(l10n.p_train_selection_date_not_today_warning);
      expect(warningMessage, findsOneWidget);
    });

    testWidgets('test can not select day before yesterday', (tester) async {
      await prepareAndStartApp(tester);

      final today = DateTime.now();
      final dayBeforeYesterday = today.add(Duration(days: -2));

      final todayDateTextFinder = find.text(Format.date(today));
      final dayBeforeYesterdayDateTextFinder = find.text(Format.date(dayBeforeYesterday));

      // Verify that today is preselected
      expect(todayDateTextFinder, findsOneWidget);
      expect(dayBeforeYesterdayDateTextFinder, findsNothing);

      await tapElement(tester, todayDateTextFinder, warnIfMissed: false);

      final datePicker = find.byKey(JourneyDatePicker.datePickerKey);
      final dayBeforeYesterdayFinder = find.descendant(
        of: datePicker,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == Format.dateWithTextMonth(dayBeforeYesterday, appLocale()),
        ),
      );
      expect(dayBeforeYesterdayFinder, findsNothing);

      await tester.pumpAndSettle();

      // Verify that today is still selected
      expect(todayDateTextFinder, findsOneWidget);
      expect(dayBeforeYesterdayDateTextFinder, findsNothing);
    });

    testWidgets('test error if JP unavailable', (tester) async {
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

      expect(find.text('${l10n.c_error_code}: ${JpUnavailable().code}'), findsOneWidget);
      expect(find.text(l10n.c_error_sfera_jp_unavailable), findsOneWidget);
    });
  });
}
