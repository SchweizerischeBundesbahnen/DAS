import 'package:app/widgets/company_selection/select_company_modal_controller.dart';
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
  late SelectCompanyModalController testee;
  final mockOnCompaniesUpdated = MockOnCompaniesUpdated();
  final List<List<Company>> emitRegister = [];

  setUp(() async {
    testee = SelectCompanyModalController(
      availableCompanies: _availableCompanies,
      initialCompanyCodes: [_sbbP.code],
      onCompaniesUpdated: mockOnCompaniesUpdated.call,
    );
    testee.filteredCompanies.listen(emitRegister.add);
    await processStreams();
    emitRegister.clear();
  });

  tearDown(() {
    reset(mockOnCompaniesUpdated);
    emitRegister.clear();
    testee.dispose();
  });

  group('SelectCompanyModalController Unit Test', () {
    test('filterValue_whenInstantiatedWithSelection_isEmpty', () {
      expect(testee.filterValue, isEmpty);
      expect(testee.textEditingController.text, isEmpty);
    });

    test('filteredCompanies_whenInstantiated_thenIsEmittedWithAllCompaniesSortedCorrectly', () async {
      // ACT
      testee = SelectCompanyModalController(
        availableCompanies: _availableCompanies,
        initialCompanyCodes: [_sbbP.code],
        onCompaniesUpdated: mockOnCompaniesUpdated.call,
      );
      testee.filteredCompanies.listen(emitRegister.add);
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, orderedEquals(_sortedCompanyValues()));
    });

    test('filterValue_whenFilterChanged_thenIsNewFilter', () {
      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      expect(testee.filterValue, equals('sob'));
    });

    test('filteredCompanies_whenFilterChanged_thenIsEmittedWithCompaniesFilteredCorrectly', () async {
      // ARRANGE
      testee.selectedCompanyCodes = [_sbbCH.code];
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = 'sb';
      await processStreams();

      // EXPECT
      // the selected company is ordered 0th even though not lexicographically the 0th element
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, orderedEquals(<Company>[_sbbCH, _sbbCInt, _sbbD, _sbbI, _sbbP]));
    });

    test('filteredCompanies_whenFilterIsWeird_thenIsEmittedEmpty', () async {
      // ACT
      testee.textEditingController.text = '#21';
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, isEmpty);
    });

    test('filteredCompanies_whenSelectionChanged_thenIsEmittedOnceWithAllCompaniesSortedCorrectly', () async {
      // ARRANGE
      testee.textEditingController.text = 'sb';
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.selectedCompanyCodes = [_sbbCH.code];
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, orderedEquals(_sortedCompanyValues(selectedCompanyCode: _sbbCH.code)));
    });

    test('filteredCompanies_whenFilterChangedAfterSelectionChanged_thenIsStillEmitted', () async {
      // ARRANGE
      testee.selectedCompanyCodes = [_sbbCH.code];
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.textEditingController.text = 'sob';
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, orderedEquals(<Company>[_sob]));
    });

    test('filterValue_whenSelectionChanged_thenIsCleared', () {
      // ARRANGE
      testee.textEditingController.text = 'sb';

      // ACT
      testee.selectedCompanyCodes = [_sbbCH.code];

      // EXPECT
      expect(testee.filterValue, isEmpty);
      expect(testee.textEditingController.text, isEmpty);
    });

    test('filterValue_whenCompanyToggled_thenIsCleared', () {
      // ARRANGE
      testee.textEditingController.text = 'sb';

      // ACT
      testee.toggleCompany(_sob.code, isSelected: true);

      // EXPECT
      expect(testee.filterValue, isEmpty);
      expect(testee.textEditingController.text, isEmpty);
    });

    test('selectedCompanyCodes_whenCompanyToggled_thenContainsOnlyTheSelectedCompanies', () {
      // ACT
      testee.toggleCompany(_sob.code, isSelected: true);

      // EXPECT
      expect(testee.selectedCompanyCodes, orderedEquals([_sbbP.code, _sob.code]));

      // ACT
      testee.toggleCompany(_sbbP.code, isSelected: false);

      // EXPECT
      expect(testee.selectedCompanyCodes, orderedEquals([_sob.code]));
    });

    test('filteredCompanies_whenAvailableCompaniesChanged_thenIsEmittedWithNewCompanies', () async {
      // ARRANGE
      testee.textEditingController.text = 'sb';
      await processStreams();
      emitRegister.clear();

      // ACT
      testee.availableCompanies = [_sob, _blsC];
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.single, orderedEquals(<Company>[_blsC, _sob]));
    });

    test('onCompaniesUpdated_whenFilterChanged_thenIsNotCalled', () {
      // ACT
      testee.textEditingController.text = 'sob';

      // EXPECT
      verifyNever(mockOnCompaniesUpdated(any));
    });

    test('onCompaniesUpdated_whenSelectionChanged_thenIsNotCalled', () {
      // ACT
      testee.selectedCompanyCodes = [_sob.code];
      testee.toggleCompany(_blsC.code, isSelected: true);

      // EXPECT
      verifyNever(mockOnCompaniesUpdated(any));
    });

    test('onCompaniesUpdated_whenSelectionConfirmed_thenIsCalledWithSelectedCompanies', () {
      // ARRANGE
      testee.selectedCompanyCodes = [_sob.code];

      // ACT
      testee.confirmSelection();

      // EXPECT
      verify(mockOnCompaniesUpdated([_sob])).called(1);
    });

    test('selectedCompanyCodes_whenInitialListIsModified_thenIsNotAffected', () {
      // ARRANGE
      final initialCompanyCodes = [_sbbP.code];
      testee = SelectCompanyModalController(
        availableCompanies: _availableCompanies,
        initialCompanyCodes: initialCompanyCodes,
        onCompaniesUpdated: mockOnCompaniesUpdated.call,
      );

      // ACT
      initialCompanyCodes.add(_sob.code);

      // EXPECT
      expect(testee.selectedCompanyCodes, orderedEquals([_sbbP.code]));
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

class MockOnCompaniesUpdated extends Mock {
  void call(List<Company>? update);
}
