import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/gen/app_localizations.dart';
import 'package:app/pages/journey/selection/journey_railway_undertaking_filter_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'fake_focus_node.dart';

void main() {
  late JourneyRailwayUndertakingFilterController testee;
  late AppLocalizations localizations;
  late FakeFocusNode fakeFocusNode;
  final mockUpdateAvailableRuFunction = MockUpdateAvailableRuFunction();
  final mockUpdateIsSelectingRailwayUndertaking = MockUpdateIsSelectingRailwayUndertaking();

  setUp(() {
    localizations = lookupAppLocalizations(const Locale('en'));
    fakeFocusNode = FakeFocusNode();
    testee = JourneyRailwayUndertakingFilterController(
      localizations: localizations,
      updateAvailableRailwayUndertakings: mockUpdateAvailableRuFunction.call,
      updateIsSelectingRailwayUndertaking: mockUpdateIsSelectingRailwayUndertaking.call,
      initialRailwayUndertaking: RailwayUndertaking.sbbP,
      focusNode: fakeFocusNode,
    );
  });

  tearDown(() {
    reset(mockUpdateAvailableRuFunction);
    testee.dispose();
  });

  String englishLocalized(RailwayUndertaking ru) => ru.localizedText(localizations);

  group('JourneyRailwayUndertakingFilterController Unit Test', () {
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

    test('filterValue_whenFocusNodeIsGettingFocused_thenDoesNothing', () {
      // ARRANGE
      testee.textEditingController.text = 'SomeText';

      // ACT
      fakeFocusNode.hasFocus = true;

      // EXPECT
      expect(testee.filterValue, equals('SomeText'));
    });

    test('filterValue_whenFocusNodeFocusedThenUnfocused_thenResetsToSelectedRailwayUndertaking', () {
      // ARRANGE
      testee.textEditingController.text = 'SomeText';
      fakeFocusNode.hasFocus = true;
      expect(testee.filterValue, equals('SomeText'));

      // ACT
      fakeFocusNode.hasFocus = false;

      // EXPECT
      expect(testee.filterValue, equals(englishLocalized(RailwayUndertaking.sbbP)));
    });

    test('updateAvailableRu_whenFocusNodeFocused_thenIsCalledWithFilter', () {
      // ACT
      fakeFocusNode.hasFocus = true;

      // EXPECT
      verify(mockUpdateAvailableRuFunction([RailwayUndertaking.sbbP, RailwayUndertaking.sbbC])).called(1);
    });

    test('updateAvailableRu_whenFocusNodeFocusLost_thenIsNotCalled', () {
      // ARRANGE
      fakeFocusNode.hasFocus = true;
      reset(mockUpdateAvailableRuFunction);

      // ACT
      fakeFocusNode.hasFocus = false;

      // EXPECT
      verifyNever(mockUpdateAvailableRuFunction(any));
    });

    test('updateAvailableRu_whenFilterChanged_thenIsCalledWithUpdatedFilter', () {
      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      verify(mockUpdateAvailableRuFunction([RailwayUndertaking.sob])).called(1);
    });

    test('updateAvailableRu_whenEmptyFilter_thenIsCalledWithAllRailwayUndertakings', () {
      // ARRANGE
      reset(mockUpdateAvailableRuFunction);

      // ACT
      testee.textEditingController.text = '';

      // EXPECT
      verify(mockUpdateAvailableRuFunction(_sortedRailwayValues(localizations))).called(1);
    });

    test('updateIsSelectingRailwayUndertaking_whenFocusUnchanged_thenDoesNotCall', () {
      // ARRANGE
      fakeFocusNode.hasFocus = true;
      reset(mockUpdateIsSelectingRailwayUndertaking);

      // ACT
      fakeFocusNode.hasFocus = true;

      // EXPECT
      verifyNever(mockUpdateIsSelectingRailwayUndertaking(any));
    });

    test('updateIsSelectingRailwayUndertaking_whenFocusNodeFocusLost_thenDoesCallWithCorrectValue', () {
      // ARRANGE
      fakeFocusNode.hasFocus = true;
      reset(mockUpdateIsSelectingRailwayUndertaking);

      // ACT
      fakeFocusNode.hasFocus = false;

      // EXPECT
      verify(mockUpdateIsSelectingRailwayUndertaking(false)).called(1);
    });
  });
}

List<RailwayUndertaking> _sortedRailwayValues(AppLocalizations localizations) {
  return RailwayUndertaking.values
      .map((ru) => (ru.localizedText(localizations).toLowerCase().trim(), ru))
      .sorted((a, b) => a.$1.compareTo(b.$1))
      .map((ruPair) => ruPair.$2)
      .toList();
}

class MockUpdateAvailableRuFunction extends Mock {
  void call(List<RailwayUndertaking>? railwayUndertakings);
}

class MockUpdateIsSelectingRailwayUndertaking extends Mock {
  void call(bool? update);
}
