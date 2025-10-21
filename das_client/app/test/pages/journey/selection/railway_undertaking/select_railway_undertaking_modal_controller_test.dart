import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/gen/app_localizations.dart';
import 'package:app/pages/journey/selection/railway_undertaking/select_railway_undertaking_modal_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';

void main() {
  late SelectRailwayUndertakingModalController testee;
  late AppLocalizations localizations;
  final mockUpdateAvailableRuFunction = MockUpdateRailwayUndertaking();
  final List<RailwayUndertaking> emitRegister = [];

  setUp(() async {
    localizations = lookupAppLocalizations(const Locale('en'));
    testee = SelectRailwayUndertakingModalController(
      localizations: localizations,
      initialRailwayUndertaking: RailwayUndertaking.sbbP,
      updateRailwayUndertaking: mockUpdateAvailableRuFunction.call,
    );
    testee.availableRailwayUndertakings.listen(emitRegister.addAll);
    await processStreams();
    emitRegister.clear();
  });

  tearDown(() {
    reset(mockUpdateAvailableRuFunction);
    emitRegister.clear();
    testee.dispose();
  });

  String englishLocalized(RailwayUndertaking ru) => ru.localizedText(localizations);

  group('SelectRailwayUndertakingModalController Unit Test', () {
    test('filterValue_whenInstantiatedWithDefault_isLocalizedString', () {
      expect(testee.filterValue, equals(englishLocalized(RailwayUndertaking.sbbP)));
    });

    test('filterValue_whenSelectedRailwayUndertakingChanged_thenUpdatesTextController', () {
      // ARRANGE
      final newRu = RailwayUndertaking.blsC;

      // ACT
      testee.selectedRailwayUndertaking = newRu;

      // EXPECT
      expect(testee.filterValue, equals(englishLocalized(RailwayUndertaking.blsC)));
    });

    test('filterValue_whenFilterChanged_thenIsNewFilter', () {
      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      expect(testee.filterValue, equals('sob'));
    });

    test('availableRailwayUndertakings_whenInitialized_thenIsEmittedWithAllUndertakingsSortedCorrectly', () async {
      // ACT
      testee = SelectRailwayUndertakingModalController(
        localizations: localizations,
        initialRailwayUndertaking: RailwayUndertaking.sbbP,
        updateRailwayUndertaking: mockUpdateAvailableRuFunction.call,
      );
      testee.availableRailwayUndertakings.listen(emitRegister.addAll);
      await processStreams();

      // EXPECT
      expect(emitRegister, orderedEquals(_sortedRailwayValues(localizations)));
    });

    test('availableRailwayUndertakings_whenFilterChanged_thenIsEmittedWithUndertakingsFilteredCorrectly', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      testee.selectedRailwayUndertaking = RailwayUndertaking.sbbC;
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = 'sb';
      await processStreams();

      // EXPECT
      expect(
        emitRegister,
        orderedEquals([RailwayUndertaking.sbbC, RailwayUndertaking.sbbP]),
      );
    });

    test('availableRailwayUndertakings_whenFilterIsEmpty_thenIsEmittedWithAllUndertakingsSortedCorrectly', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      final newRu = RailwayUndertaking.sbbC;
      testee.selectedRailwayUndertaking = newRu;
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = '';
      await processStreams();

      // EXPECT
      expect(
        emitRegister,
        orderedEquals(_sortedRailwayValues(localizations, selectedRailwayUndertaking: newRu)),
      );
    });

    test('availableRailwayUndertakings_whenFilterIsWeird_thenIsEmittedEmpty', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      final newRu = RailwayUndertaking.sbbC;
      testee.selectedRailwayUndertaking = newRu;
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = '#21';
      await processStreams();

      // EXPECT
      expect(emitRegister, isEmpty);
    });

    test('updateIsSelectingRailwayUndertaking_whenFilterChanged_thenIsNotCalled', () {
      // ARRANGE
      reset(mockUpdateAvailableRuFunction);

      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      verifyNever(mockUpdateAvailableRuFunction(any));
    });

    test('updateIsSelectingRailwayUndertaking_whenSetSelectedRuCalled_thenIsCalled', () {
      // ARRANGE
      final newRu = RailwayUndertaking.sob;
      reset(mockUpdateAvailableRuFunction);

      // ACT
      testee.selectedRailwayUndertaking = newRu;

      // EXPECT
      verify(mockUpdateAvailableRuFunction(newRu)).called(1);
    });
  });
}

List<RailwayUndertaking> _sortedRailwayValues(
  AppLocalizations localizations, {
  selectedRailwayUndertaking = RailwayUndertaking.sbbP,
}) {
  return RailwayUndertaking.knownRUs
      .map((ru) => (ru.localizedText(localizations).toLowerCase().trim(), ru))
      .sortedBy((pair) => pair.$2 == selectedRailwayUndertaking ? '' : pair.$1)
      .map((ruPair) => ruPair.$2)
      .toList();
}

class MockUpdateRailwayUndertaking extends Mock {
  void call(RailwayUndertaking? update);
}
