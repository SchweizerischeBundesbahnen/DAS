import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

import '../app_test.dart';
import '../mocks/mock_train_identification_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('train search screen tests', () {
    testWidgets('trainSearch_whenPageLoaded_thenShowsDefaultValues', (tester) async {
      await prepareAndStartApp(tester);

      // Verify that today is preselected
      expect(find.text(Format.date(DateTime.now())), findsOneWidget);
    });

    testWidgets('trainSearch_whenRuSelectionOpened_thenShowsOptions', (tester) async {
      await prepareAndStartApp(tester);

      await tapElement(tester, find.text(l10n.p_train_selection_ru_description), warnIfMissed: false);

      // Verify modal is opened
      final modal = find.byKey(SelectRailwayUndertakingModal.modalKey);
      expect(modal, findsOneWidget);

      expect(find.text(l10n.c_ru_db), findsOneWidget);
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_bls_p)), findsOneWidget);
      expect(find.text(l10n.c_ru_bls_c), findsOneWidget);
      final sobI = find.text(l10n.c_ru_sob);
      await tester.dragUntilVisible(sobI, modal, const Offset(0, -50));
      expect(sobI, findsOneWidget);
      await tapElement(tester, sobI, warnIfMissed: false);
      expect(sobI, findsOneWidget);
    });

    testWidgets('trainSearch_whenRuFilterEntered_thenFiltersResults', (tester) async {
      await prepareAndStartApp(tester);

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
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_sbb_p)), findsNothing);
      expect(find.descendant(of: modal, matching: find.text(l10n.c_ru_bls_p)), findsNothing);
      expect(find.text(l10n.c_ru_sob), findsOneWidget);
    });

    testWidgets('trainSearch_whenNoTrainNumberEntered_thenDisablesButton', (tester) async {
      await prepareAndStartApp(tester);

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

    testWidgets('trainSearch_whenYesterdaySelected_thenShowsWarning', (tester) async {
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

    testWidgets('trainSearch_whenDayBeforeYesterday_thenCannotSelect', (tester) async {
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

    testWidgets('trainSearch_whenJpUnavailable_thenShowsError', (tester) async {
      await prepareAndStartApp(tester);

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

    testWidgets('trainSearch_whenErrorFromSfera_thenDisplaysErrorCode', (tester) async {
      await prepareAndStartApp(tester);

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

    testWidgets('trainSearch_whenMultipleCompanyMatches_thenShowsSelection', (tester) async {
      await prepareAndStartApp(tester);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;

      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsI,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.thurbo,
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

    testWidgets('trainSearch_whenLastRuRemembered_thenAutoSelects', (tester) async {
      await prepareAndStartApp(tester);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;

      final userSettings = DI.get<UserSettings>();
      userSettings.set(UserSettingKeys.lastUsedRailwayUndertaking, RailwayUndertaking.sbbP.companyCode);

      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsI,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.thurbo,
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

    testWidgets('trainSearch_whenNoCompanyMatch_thenShowsNoResultMessage', (tester) async {
      await prepareAndStartApp(tester);

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
