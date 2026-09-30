import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/detail_tab_communication.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/personal_note_dialog.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/basic_text_accordion.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_text_field.dart';
import 'package:app/util/format.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes/component.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_personal_notes_repository.dart';
import '../mocks/mock_settings_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('personalNotes_whenCreateThenUpdateNote_thenUpdatesModal|1VehH7uMXywgKQOOzOIC|tests:1009', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');

    // check that no personal note exists and open create dialog
    _checkModalHasNoPersonalNote();
    await tapElement(tester, find.byKey(DetailTabCommunication.createPersonalNoteButtonKey));
    await _awaitAndCheckCreateDialog(tester);

    // add new personal note
    final text = 'This is a new personal note';
    await enterText(tester, _findPersonalNoteTextArea(), text);
    await tapElement(tester, find.byKey(PersonalNoteDialog.saveButtonKey));

    await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));
    _checkModalHasPersonalNoteWithText(text);

    await disconnect(tester);
  });

  testWidgets(
    'personalNotes_whenExistingSingleUseAndGeneralAndDeleteAfterwards_thenShowsSingleUseThenGeneralThenNothing|4uZZWz3SWW0IYo7oidAJ|tests:1009',
    (tester) async {
      await IntegrationTestApp.start(tester);

      // initialize personal note repository with two personal notes on Bahnhof A
      final company = companySBBP;
      final now = DateTime.now();
      final todayTrimmedToDay = DateTime(now.year, now.month, now.day);
      final generalNote = PersonalNote(locationCode: 'CH09991', text: 'Test General', showAsFootnote: false);
      final singleUseNote = PersonalNote(
        locationCode: 'CH09991',
        text: 'Test Single Use',
        showAsFootnote: false,
        trainIdentification: TrainIdentification(
          companyCode: company.code,
          trainNumber: 'T9999M',
          date: todayTrimmedToDay,
          operatingDay: DateTime(2025, 12, 1),
        ),
      );
      final singleUseNoteOnOtherDay = PersonalNote(
        locationCode: 'CH09991',
        text: 'Test Single Use on other day',
        showAsFootnote: false,
        trainIdentification: TrainIdentification(
          companyCode: company.code,
          trainNumber: 'T9999M',
          date: todayTrimmedToDay.subtract(Duration(days: 3)),
          operatingDay: DateTime(2025, 12, 1),
        ),
      );

      final personalNotesRepository = DI.get<PersonalNotesRepository>() as MockPersonalNotesRepository;
      personalNotesRepository.initializeWith([generalNote, singleUseNote, singleUseNoteOnOtherDay]);

      await loadJourney(tester, trainNumber: 'T9999M', company: company);

      await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');

      // check that single use note is prioritized
      _checkModalHasPersonalNoteWithText(singleUseNote.text);

      // warn message should be shown that there is a general note hidden
      expect(find.text(l10n.w_service_point_modal_personal_hidden_note_information), findsOne);

      // open dialog and delete single use note
      await tapElement(tester, find.byKey(DetailTabCommunication.editPersonalNoteButtonKey));
      await _awaitAndCheckEditDialog(tester, singleUseNote.text);
      await tapElement(tester, find.byKey(PersonalNoteDialog.deleteButtonKey));
      await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));

      // check that now the general note is shown
      _checkModalHasPersonalNoteWithText(generalNote.text);

      // warn message should not be shown anymore
      expect(find.text(l10n.w_service_point_modal_personal_hidden_note_information), findsNothing);

      // open dialog and also delete general note
      await tapElement(tester, find.byKey(DetailTabCommunication.editPersonalNoteButtonKey));
      await _awaitAndCheckEditDialog(tester, generalNote.text);
      await tapElement(tester, find.byKey(PersonalNoteDialog.deleteButtonKey));
      await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));

      // check that note is not shown anymore
      await tester.pumpAndSettle();
      _checkModalHasNoPersonalNote();

      await disconnect(tester);
    },
  );

  testWidgets('personalNotes_whenCreateNoteAsFootNoteThenDelete_thenUpdatesJourneyTable|3ZCteqwJAfzRLMjae4uy|tests:1009', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');

    // check that no personal note exists and open create dialog
    _checkModalHasNoPersonalNote();
    await tapElement(tester, find.byKey(DetailTabCommunication.createPersonalNoteButtonKey));
    await _awaitAndCheckCreateDialog(tester);

    // add new personal note as foot note
    final text = 'This is a personal note that is shown as foot note';
    await enterText(tester, _findPersonalNoteTextArea(), text);
    await tapElement(tester, find.byKey(PersonalNoteDialog.showAsFootNoteSwitchKey));
    await tapElement(tester, find.byKey(PersonalNoteDialog.saveButtonKey));
    await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));

    _checkModalHasPersonalNoteWithText(text);

    // check that foot note exists
    expect(findDASTableRowByText(text), findsOne);

    // open dialog and delete note
    await tapElement(tester, find.byKey(DetailTabCommunication.editPersonalNoteButtonKey));
    await _awaitAndCheckEditDialog(tester, text);
    await tapElement(tester, find.byKey(PersonalNoteDialog.deleteButtonKey));
    await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));

    // check that foot note is removed
    expect(find.descendant(of: find.byType(BasicTextAccordion), matching: find.text(text)), findsNothing);

    await disconnect(tester);
  });

  testWidgets(
    'personalNotes_whenCreateSingleUseNote_thenOnlyShowsInCurrentJourney|UBhcHMmWcVTq6qejZjrJ|tests:1009',
    (tester) async {
      await IntegrationTestApp.start(tester);

      final today = DateTime.now();
      await loadJourney(tester, trainNumber: 'T9999M', company: companySBBP);

      await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');

      // check that no personal note exists and open create dialog
      _checkModalHasNoPersonalNote();
      await tapElement(tester, find.byKey(DetailTabCommunication.createPersonalNoteButtonKey));
      await _awaitAndCheckCreateDialog(tester);

      // add new personal note as single use
      final text = 'This is a personal note that is used only on this journey';
      await enterText(tester, _findPersonalNoteTextArea(), text);
      await tapElement(tester, find.byKey(PersonalNoteDialog.singleUseSwitchKey));
      await tapElement(tester, find.byKey(PersonalNoteDialog.saveButtonKey));
      await waitUntilNotExists(tester, find.byKey(PersonalNoteDialog.dialogKey));

      // check that now the note is shown
      _checkModalHasPersonalNoteWithText(text);

      // open journey for yesterday and check that note does not exist
      await stopAutomaticAdvancement(tester);
      await closeJourney(tester);
      await tester.pumpAndSettle();
      await tapElement(tester, find.byType(JourneyDateTextField));
      await tester.pumpAndSettle();
      final yesterday = today.add(Duration(days: -1));
      final yesterdayFinder = find.descendant(
        of: find.byKey(JourneyDatePicker.datePickerKey),
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == Format.dateWithTextMonth(yesterday, appLocale()),
        ),
      );
      await tapElement(tester, yesterdayFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      await loadJourney(tester, trainNumber: 'T9999M', company: companySBBP);
      await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');
      _checkModalHasNoPersonalNote();

      // open journey with other company and check that note does not exist
      await stopAutomaticAdvancement(tester);
      await closeJourney(tester);
      await loadJourney(
        tester,
        trainNumber: 'T9999M',
        company: companyBLSC,
      );
      await _openModalByTapOnCellWithText(tester, '(Bahnhof A)');
      _checkModalHasNoPersonalNote();

      await disconnect(tester);
    },
  );
}

Finder _findPersonalNoteTextArea() {
  final textArea = find.byKey(PersonalNoteDialog.textAreaKey);
  return find.descendant(of: textArea, matching: find.byType(EditableText));
}

Future<void> _awaitAndCheckEditDialog(WidgetTester tester, String text) async {
  final dialog = find.byKey(PersonalNoteDialog.dialogKey);
  await waitUntilExists(tester, dialog);
  expect(find.byKey(PersonalNoteDialog.deleteButtonKey), findsOne);
  expect(find.descendant(of: dialog, matching: find.text(text)), findsOne);
  expect(find.byKey(DetailTabCommunication.editPersonalNoteButtonKey), findsOne);
  expect(find.byKey(DetailTabCommunication.createPersonalNoteButtonKey), findsNothing);
}

Future<void> _awaitAndCheckCreateDialog(WidgetTester tester) async {
  await waitUntilExists(tester, find.byKey(PersonalNoteDialog.dialogKey));
  expect(find.byKey(PersonalNoteDialog.deleteButtonKey), findsNothing);
}

void _checkModalHasPersonalNoteWithText(String text) {
  final personalNoteContainer = find.byKey(DetailTabCommunication.personalNoteContainerKey);
  expect(personalNoteContainer, findsOne);
  expect(find.descendant(of: personalNoteContainer, matching: find.text(text)), findsOne);
  expect(find.byKey(DetailTabCommunication.editPersonalNoteButtonKey), findsOne);
  expect(find.byKey(DetailTabCommunication.createPersonalNoteButtonKey), findsNothing);
}

void _checkModalHasNoPersonalNote() {
  expect(find.byKey(DetailTabCommunication.personalNoteContainerKey), findsNothing);
  expect(find.byKey(DetailTabCommunication.editPersonalNoteButtonKey), findsNothing);
  expect(find.byKey(DetailTabCommunication.createPersonalNoteButtonKey), findsOne);
}

Future<void> _openModalByTapOnCellWithText(WidgetTester tester, String cellText) async {
  final tableRow = findDASTableRowByText(cellText);
  final cell = find.descendant(of: tableRow, matching: find.text(cellText));
  await tapElement(tester, cell, warnIfMissed: false);
}
