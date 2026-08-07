import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_settings_repository.dart';
import '../mocks/mock_train_identification_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('train search screen tests', () {
    testWidgets('trainSearch_whenPageLoaded_thenShowsDefaultValues|yJsLvmX6PrhDbt3GNctg|tests:92', (tester) async {
      await IntegrationTestApp.start(tester);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);
    });

    testWidgets('trainSearch_whenRuSelectionOpened_thenShowsOptions|4V8lVLIAXkStk9lkHcFv|tests:92', (tester) async {
      await IntegrationTestApp.start(tester);

      await tapElement(tester, find.text(l10n.p_train_selection_ru_description), warnIfMissed: false);

      // Verify modal is opened
      final modal = find.byKey(SelectRailwayUndertakingModal.modalKey);
      expect(modal, findsOneWidget);

      expect(find.text(companyDB.shortName), findsOneWidget);
      expect(find.descendant(of: modal, matching: find.text(companyBLSP.shortName)), findsOneWidget);
      expect(find.text(companyBLSC.shortName), findsOneWidget);
      final sobI = find.text(companySOB.shortName);
      await tester.dragUntilVisible(sobI, modal, const Offset(0, -50));
      expect(sobI, findsOneWidget);
      await tapElement(tester, sobI, warnIfMissed: false);
      expect(sobI, findsOneWidget);
    });

    testWidgets('trainSearch_whenRuFilterEntered_thenFiltersResults|K9LxJibBfWA0sakjBxjU|tests:596', (tester) async {
      await IntegrationTestApp.start(tester);

      await tapElement(tester, find.text(l10n.p_train_selection_ru_description), warnIfMissed: false);

      // Verify modal is opened
      final modal = find.byKey(SelectRailwayUndertakingModal.modalKey);
      expect(modal, findsOneWidget);

      // Enter filter 'SO'
      final filterField = find.byKey(SelectRailwayUndertakingModal.filterFieldKey);
      expect(filterField, findsOneWidget);
      await enterText(tester, filterField, 'SO');
      await tester.pumpAndSettle();

      // Verify results are filtered
      expect(find.descendant(of: modal, matching: find.text(companySBBP.shortName)), findsNothing);
      expect(find.descendant(of: modal, matching: find.text(companyBLSP.shortName)), findsNothing);
      expect(find.text(companySOB.shortName), findsOneWidget);
    });

    testWidgets('trainSearch_whenNoTrainNumberEntered_thenDisablesButton|3JEyvxxjnxVGfeAOufjK|tests:92', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      // Verify that no train number is there
      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);
    });

    testWidgets('trainSearch_whenYesterdaySelected_thenShowsWarning|Rh6SvdbhmUIBNyDfPXfO|tests:92', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('trainSearch_whenDayBeforeYesterday_thenCannotSelect|t4mNyzwoakPFwz6CYPka|tests:92', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('trainSearch_whenJpUnavailable_thenShowsError|IPmnmRoSSpBBs6aHadTk|tests:92', (tester) async {
      await IntegrationTestApp.start(tester);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '1234');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.text('${l10n.c_error_code}: ${JpUnavailable().code}'), findsOneWidget);
      expect(find.text(l10n.c_error_sfera_jp_unavailable), findsOneWidget);
    });

    testWidgets('trainSearch_whenErrorFromSfera_thenDisplaysErrorCode|9UIII436R7pMUXwLx6zR|tests:652', (tester) async {
      await IntegrationTestApp.start(tester);

      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T34');

      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tapElement(tester, primaryButton);

      // general error code for sfera protocol errors
      expect(find.text('${l10n.c_error_code}: ${ProtocolErrors().code}'), findsOneWidget);

      // specific error code expected from SFERA response without additional info
      expect(find.text('${l10n.c_error_code} 50: ${l10n.c_error_sfera_no_additional_info}'), findsOneWidget);
    });

    testWidgets('trainSearch_whenMultipleCompanyMatches_thenShowsSelection|edyQLmRIb617kcxR5XXN|tests:702,703', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;

      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(companyCode: '1285', startDate: DateTime.now()),
        CompanyMatch(companyCode: '2263', startDate: DateTime.now()),
        CompanyMatch(
          companyCode: '3917',
          startDate: DateTime.now().add(Duration(days: 1)),
        ),
      };

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T10');

      // check that the primary button is disabled
      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.text('1285, SBBP'), findsOneWidget);
      expect(find.text('2263, BLSI'), findsOneWidget);
      expect(find.text('3917, THURBO'), findsNothing);

      primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);

      await tapElement(tester, find.text('1285, SBBP'));

      primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.byType(JourneySelectionPage), findsNothing);
      expect(find.byType(JourneyPage), findsAny);

      await disconnect(tester);
    });

    testWidgets('trainSearch_whenLastRuRemembered_thenAutoSelects|G6t83P9j45q6KfT4Y70f|tests:702', (tester) async {
      await IntegrationTestApp.start(tester);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;

      final userSettings = DI.get<LocalKeyValueStore>();
      userSettings.set(.lastUsedCompanyCode, RailwayUndertaking.sbbP.companyCode);

      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(companyCode: '1285', startDate: DateTime.now()),
        CompanyMatch(companyCode: '2263', startDate: DateTime.now()),
        CompanyMatch(
          companyCode: '3917',
          startDate: DateTime.now().add(Duration(days: 1)),
        ),
      };

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T10');

      // check that the primary button is disabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.byType(JourneySelectionPage), findsNothing);
      expect(find.byType(JourneyPage), findsAny);

      await disconnect(tester);
    });

    testWidgets('trainSearch_whenNoCompanyMatch_thenShowsNoResultMessage|WQ4rTB8lZNGl5HW7Dbq0|tests:702', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;

      trainIdentificationRepository.companyMatchData = {};

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);

      final trainNumberText = findTextInputByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T10');

      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await tapElement(tester, primaryButton);

      expect(find.text(l10n.p_train_selection_no_match_title), findsOneWidget);
      expect(find.byType(SBBRadioGroup), findsNothing);

      // check that the primary button is disabled
      primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);
    });
  });
}
