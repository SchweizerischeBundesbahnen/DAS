import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('SelectCompanyModalController');

/// This Controller is responsible for filtering names of companies.
///
/// The results are ordered alphabetically with the currently selected one always on top.
class SelectCompanyModalController({
  required final List<Company> availableCompanies,
  required final void Function(List<Company>) updateCompanies,
  required List<String> initialCompanyCodes,
  required final bool allowMultiSelect,
}) {
  this {
    _selectedCompanyCodes = initialCompanyCodes;
    _init();
  }

  late TextEditingController _textController;
  String? _filter;
  late List<String> _selectedCompanyCodes;
  late BehaviorSubject<List<Company>> _rxFilteredCompanies;

  TextEditingController get textEditingController => _textController;

  // for testing convenience
  @visibleForTesting
  String? get filterValue => _filter;

  Stream<List<Company>> get filteredCompanies => _rxFilteredCompanies.stream.distinct();

  set selectedCompanyCodes(List<String> selectedCompanyCodes) {
    _selectedCompanyCodes = selectedCompanyCodes;
    if (!allowMultiSelect) {
      _resetToSelectedCompany();
    }
    updateCompanies.call(_selectedCompanies());
  }

  void dispose() {
    _rxFilteredCompanies.close();
    _textController.removeListener(_onTextControllerChanged);
    _textController.dispose();
  }

  void _init() {
    _initRxFilteredCompanies();
    _initFilter();
    _initTextEditingController();
  }

  void _initRxFilteredCompanies() {
    final companies = availableCompanies.sortedAlphabeticallyWithSelectedFirst(_selectedCompanyCodes);
    _rxFilteredCompanies = BehaviorSubject<List<Company>>.seeded(companies);
  }

  void _initFilter() {
    if (!allowMultiSelect) {
      _filter = _selectedCompanies().firstOrNull?.shortName;
    }
  }

  void _initTextEditingController() {
    _textController = TextEditingController(text: _filter);
    _textController.addListener(_onTextControllerChanged);
  }

  void _resetToSelectedCompany() {
    _filter = _selectedCompanies().firstOrNull?.shortName;
    _textController.text = _filter ?? '';
  }

  void _onTextControllerChanged() {
    final filterHasChanged = _textController.text != _filter;
    if (!filterHasChanged) return;
    _filter = _textController.text;

    final search = _filter!.toLowerCase().trim();
    final filteredResult = availableCompanies
        .where((company) => company.shortName.toLowerCase().startsWith(search))
        .sortedAlphabeticallyWithSelectedFirst(_selectedCompanyCodes);

    _log.finer('Filtered companies with $search to $filteredResult.');
    _rxFilteredCompanies.add(filteredResult);
  }

  List<Company> _selectedCompanies() =>
      availableCompanies.where((company) => _selectedCompanyCodes.contains(company.code)).toList();
}

extension _CompaniesSortX on Iterable<Company> {
  List<Company> sortedAlphabeticallyWithSelectedFirst(List<String> selectedCompanyCodes) => sorted(
    (a, b) => selectedCompanyCodes.contains(a.code) != selectedCompanyCodes.contains(b.code)
        ? (selectedCompanyCodes.contains(a.code) ? -1 : 1)
        : a.shortName.toLowerCase().compareTo(b.shortName.toLowerCase()),
  );
}
