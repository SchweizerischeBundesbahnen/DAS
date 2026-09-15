import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('SelectCompanyModalController');

/// This Controller is responsible for filtering names of companies.
///
/// The results are ordered alphabetically with the currently selected ones always on top.
/// Every change of the selection or of the available companies resets the filter.
class SelectCompanyModalController({
  required final List<Company> availableCompanies,
  required final void Function(List<Company>) onCompaniesUpdated,
  required List<String> initialCompanyCodes,
}) {
  this {
    _selectedCompanyCodes = List.of(initialCompanyCodes);
    _availableCompanies = List.of(availableCompanies);
    _init();
  }

  late final TextEditingController _textController;
  late final BehaviorSubject<List<Company>> _rxFilteredCompanies;
  late List<String> _selectedCompanyCodes;
  late List<Company> _availableCompanies;
  String _filter = '';

  TextEditingController get textEditingController => _textController;

  @visibleForTesting
  String get filterValue => _filter;

  Stream<List<Company>> get filteredCompanies => _rxFilteredCompanies.stream;

  List<String> get selectedCompanyCodes => List.unmodifiable(_selectedCompanyCodes);

  /// Updates the selection without propagating it. Call [confirmSelection] to propagate it.
  set selectedCompanyCodes(List<String> selectedCompanyCodes) {
    _selectedCompanyCodes = List.of(selectedCompanyCodes);
    _resetFilter();
  }

  set availableCompanies(List<Company> availableCompanies) {
    _availableCompanies = List.of(availableCompanies);
    _resetFilter();
  }

  void toggleCompany(String companyCode, {required bool isSelected}) {
    final updatedCompanyCodes = List.of(_selectedCompanyCodes);
    if (isSelected) {
      updatedCompanyCodes.add(companyCode);
    } else {
      updatedCompanyCodes.remove(companyCode);
    }
    selectedCompanyCodes = updatedCompanyCodes;
  }

  /// Propagates the current selection to the parent via [onCompaniesUpdated].
  void confirmSelection() => onCompaniesUpdated.call(_selectedCompanies());

  void dispose() {
    _rxFilteredCompanies.close();
    _textController.removeListener(_onTextControllerChanged);
    _textController.dispose();
  }

  void _init() {
    _rxFilteredCompanies = BehaviorSubject<List<Company>>.seeded(_filteredAndSortedCompanies());
    _textController = TextEditingController(text: _filter)..addListener(_onTextControllerChanged);
  }

  void _resetFilter() {
    _filter = '';
    _textController.clear();
    _emitFilteredCompanies();
  }

  void _onTextControllerChanged() {
    final filterHasChanged = _textController.text != _filter;
    if (!filterHasChanged) return;
    _filter = _textController.text;
    _emitFilteredCompanies();
  }

  void _emitFilteredCompanies() {
    final filteredResult = _filteredAndSortedCompanies();
    _log.finer('Filtered companies with $_filter to $filteredResult.');
    _rxFilteredCompanies.add(filteredResult);
  }

  List<Company> _filteredAndSortedCompanies() {
    final search = _filter.toLowerCase().trim();
    return _availableCompanies
        .where((company) => company.shortName.toLowerCase().startsWith(search))
        .sortedAlphabeticallyWithSelectedFirst(_selectedCompanyCodes);
  }

  List<Company> _selectedCompanies() =>
      _availableCompanies.where((company) => _selectedCompanyCodes.contains(company.code)).toList();
}

extension _CompaniesSortX on Iterable<Company> {
  List<Company> sortedAlphabeticallyWithSelectedFirst(List<String> selectedCompanyCodes) => sorted(
    (a, b) => selectedCompanyCodes.contains(a.code) != selectedCompanyCodes.contains(b.code)
        ? (selectedCompanyCodes.contains(a.code) ? -1 : 1)
        : a.shortName.toLowerCase().compareTo(b.shortName.toLowerCase()),
  );
}
