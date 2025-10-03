import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyRailwayUndertakingFilterController');

/// This ViewModel is responsible for filtering **localized** names of railway undertakings.
/// Thus it must access the AppLocalizations.
///
/// To simplify, it exposes and listens to a TextController for the corresponding (filter) SBBTextField.
/// It has a setter for the currently selected RailwayUndertaking.
/// It exposes a stream of available RailwayUndertakings
/// based on the TextController text value (the filtering function).
///
/// The filtering is special as all available railway undertakings are emitted before the first key stroke.
/// This allows the user to see other possibilites and intuitively understand the filter.
class JourneyRailwayUndertakingModalViewModel {
  JourneyRailwayUndertakingModalViewModel({
    required this.localizations,
    required this.updateRailwayUndertaking,
    required RailwayUndertaking initialRailwayUndertaking,
  }) {
    _selectedRailwayUndertaking = initialRailwayUndertaking;
    _init();
  }

  final AppLocalizations localizations;
  final void Function(RailwayUndertaking) updateRailwayUndertaking;

  late TextEditingController _textController;
  late RailwayUndertaking _selectedRailwayUndertaking;
  late List<(String, RailwayUndertaking)> _localizedToRailwayUndertaking;
  late BehaviorSubject<Iterable<RailwayUndertaking>> _rxAvailableRailwayUndertakings;

  TextEditingController get textEditingController => _textController;

  // for testing convenience
  @visibleForTesting
  String? get filterValue => _textController.text;

  Stream<Iterable<RailwayUndertaking>> get availableRailwayUndertakings => _rxAvailableRailwayUndertakings.stream;

  set selectedRailwayUndertaking(RailwayUndertaking selectedRailwayUndertaking) {
    _selectedRailwayUndertaking = selectedRailwayUndertaking;
    _resetControllerToSelectedRailwayUndertaking();
    updateRailwayUndertaking.call(_selectedRailwayUndertaking);
  }

  void dispose() {
    _rxAvailableRailwayUndertakings.close();
    _textController.removeListener(_filterRailwayUndertakings);
    _textController.dispose();
  }

  void _init() {
    _initRuToLocalizedMap();
    _initRxAvailableRailwayUndertakings(_selectedRailwayUndertaking);
    _initTextEditingController(_selectedRailwayUndertaking);
  }

  void _initRuToLocalizedMap() {
    _localizedToRailwayUndertaking = RailwayUndertaking.values
        .map((ru) => (ru.localizedText(localizations).toLowerCase().trim(), ru))
        .sorted((a, b) => a.$1.compareTo(b.$1));
  }

  void _initRxAvailableRailwayUndertakings(RailwayUndertaking selectedRailwayUndertaking) {
    _rxAvailableRailwayUndertakings = BehaviorSubject<List<RailwayUndertaking>>();
    _rxAvailableRailwayUndertakings.add(
      _localizedToRailwayUndertaking.sortedWithSelectedFirst(_selectedRailwayUndertaking),
    );
  }

  void _initTextEditingController(RailwayUndertaking? selectedRailwayUndertaking) {
    _textController = TextEditingController();
    _resetControllerToSelectedRailwayUndertaking();

    _textController.addListener(_filterRailwayUndertakings);
  }

  void _resetControllerToSelectedRailwayUndertaking() {
    _textController.text = _selectedRailwayUndertaking.localizedText(localizations);
  }

  void _filterRailwayUndertakings() {
    final filter = _textController.text.toLowerCase().trim();

    final filteredResult = _localizedToRailwayUndertaking
        .where((ruPair) => ruPair.$1.startsWith(filter))
        .sortedWithSelectedFirst(_selectedRailwayUndertaking);

    _log.finer('Filtered RailwayUndertakings with $filter to $filteredResult.');
    _rxAvailableRailwayUndertakings.add(filteredResult);
  }
}

extension on Iterable<(String, RailwayUndertaking)> {
  List<RailwayUndertaking> sortedWithSelectedFirst(RailwayUndertaking selectedRailwayUndertaking) =>
      sortedBy((pair) => pair.$2 == selectedRailwayUndertaking ? '' : pair.$1).map((e) => e.$2).toList();
}
