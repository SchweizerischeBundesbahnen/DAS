import 'package:app/widgets/railway_undertaking/select_railway_undertaking_modal_controller.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_util.dart';

const _blsC = Company(code: '3356', shortName: 'BLSC');
const _sbbP = Company(code: '1285', shortName: 'SBBP');
const _sbbCH = Company(code: '2185', shortName: 'SBBCH');
const _sbbI = Company(code: '5184', shortName: 'SBBI');
const _sbbD = Company(code: '2385', shortName: 'SBBD');
const _sbbCInt = Company(code: '2585', shortName: 'SBBCInt');
const _sob = Company(code: '9058', shortName: 'SOB');
const _availableCompanies = [_blsC, _sbbP, _sbbCH, _sob, _sbbI, _sbbD, _sbbCInt];

void main() {
  late SelectRailwayUndertakingModalController testee;
  final mockUpdateCompanies = MockUpdateCompanies();
  final List<Company> emitRegister = [];

  setUp(() async {
    testee = SelectRailwayUndertakingModalController(
      availableCompanies: _availableCompanies,
      initialCompanyCodes: [_sbbP.code],
      updateCompanies: mockUpdateCompanies.call,
      allowMultiSelect: false,
    );
    testee.filteredCompanies.listen(emitRegister.addAll);
    await processStreams();
    emitRegister.clear();
  });

  tearDown(() {
    reset(mockUpdateCompanies);
    emitRegister.clear();
    testee.dispose();
  });

  group('SelectRailwayUndertakingModalController Unit Test', () {
    test('filterValue_whenInstantiatedWithDefault_isLocalizedString', () {
      expect(testee.filterValue, equals(_sbbP.shortName));
    });

    test('filterValue_whenSelectedRailwayUndertakingChanged_thenUpdatesTextController', () {
      // ARRANGE
      final newCompanyCode = '3356';

      // ACT
      testee.selectedCompanyCodes = [newCompanyCode];

      // EXPECT
      expect(testee.filterValue, equals(_blsC.shortName));
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
        availableCompanies: _availableCompanies,
        initialCompanyCodes: [_sbbP.code],
        updateCompanies: mockUpdateCompanies.call,
        allowMultiSelect: false,
      );
      testee.filteredCompanies.listen(emitRegister.addAll);
      await processStreams();

      // EXPECT
      expect(emitRegister, orderedEquals(_sortedCompanyValues()));
    });

    test('availableRailwayUndertakings_whenFilterChanged_thenIsEmittedWithUndertakingsFilteredCorrectly', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      testee.selectedCompanyCodes = [_sbbCH.code];
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = 'sb';
      await processStreams();

      // EXPECT
      expect(
        emitRegister,
        orderedEquals(<Company>[
          _sbbCH,
          _sbbCInt,
          _sbbD,
          _sbbI,
          _sbbP,
        ]),
      );
    });

    test('availableRailwayUndertakings_whenFilterIsEmpty_thenIsEmittedWithAllUndertakingsSortedCorrectly', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      testee.selectedCompanyCodes = [_sbbCH.code];
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = '';
      await processStreams();

      // EXPECT
      expect(
        emitRegister,
        orderedEquals(_sortedCompanyValues(selectedCompanyCode: _sbbCH.code)),
      );
    });

    test('availableRailwayUndertakings_whenFilterIsWeird_thenIsEmittedEmpty', () async {
      // ARRANGE
      // should be ordered 0th even though not lexicographically the 0th element
      testee.selectedCompanyCodes = [_sbbCH.code];
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
      reset(mockUpdateCompanies);

      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      verifyNever(mockUpdateCompanies(any));
    });

    test('updateIsSelectingRailwayUndertaking_whenSetSelectedRuCalled_thenIsCalled', () {
      // ARRANGE
      reset(mockUpdateCompanies);

      // ACT
      testee.selectedCompanyCodes = [_sob.code];

      // EXPECT
      verify(mockUpdateCompanies([_sob])).called(1);
    });
  });
}

List<Company> _sortedCompanyValues({String selectedCompanyCode = '1285'}) {
  return _availableCompanies
      .sorted(
        (a, b) => (selectedCompanyCode == a.code) != (selectedCompanyCode == b.code)
            ? (selectedCompanyCode == a.code ? -1 : 1)
            : a.shortName.toLowerCase().compareTo(b.shortName.toLowerCase()),
      )
      .toList();
}

class MockUpdateCompanies extends Mock {
  void call(List<Company>? update);
}
