import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyRailwayUndertakingFilterController');

/// This Controller is responsible for filtering **localized** names of railway undertakings.
/// Thus it must access the AppLocalizations.
///
/// To simplify, it exposes and listens to a TextController for the corresponding (filter) SBBTextField.
/// It has a setter for the currently selected RailwayUndertaking.
/// It exposes a stream of available RailwayUndertakings
/// based on the TextController text value (the filtering function).
///
/// The filtering is special as all available railway undertakings are emitted before the first key stroke.
/// This allows the user to see other possibilities and intuitively understand the filter. The results
/// are ordered such that the currently selected one is always on top.
class SelectRailwayUndertakingModalController {
  SelectRailwayUndertakingModalController({
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
  String? _filter;
  late RailwayUndertaking _selectedRailwayUndertaking;
  late List<(String, RailwayUndertaking)> _localizedToRailwayUndertaking;
  late BehaviorSubject<List<RailwayUndertaking>> _rxAvailableRailwayUndertakings;

  TextEditingController get textEditingController => _textController;

  // for testing convenience
  @visibleForTesting
  String? get filterValue => _filter;

  Stream<List<RailwayUndertaking>> get availableRailwayUndertakings =>
      _rxAvailableRailwayUndertakings.stream.distinct();

  set selectedRailwayUndertaking(RailwayUndertaking selectedRailwayUndertaking) {
    _selectedRailwayUndertaking = selectedRailwayUndertaking;
    _resetToSelectedRailwayUndertaking();
    updateRailwayUndertaking.call(_selectedRailwayUndertaking);
  }

  void dispose() {
    _rxAvailableRailwayUndertakings.close();
    _textController.removeListener(_onTextControllerChanged);
    _textController.dispose();
  }

  void _init() {
    _initRuToLocalizedMap();
    _initRxAvailableRailwayUndertakings(_selectedRailwayUndertaking);
    _initFilter(_selectedRailwayUndertaking);
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

  void _initFilter(RailwayUndertaking selectedRailwayUndertaking) {
    _filter = _selectedRailwayUndertaking.localizedText(localizations);
  }

  void _initTextEditingController(RailwayUndertaking? selectedRailwayUndertaking) {
    _textController = TextEditingController(text: _filter);
    _textController.addListener(_onTextControllerChanged);
  }

  void _resetToSelectedRailwayUndertaking() {
    _filter = _selectedRailwayUndertaking.localizedText(localizations);
    _textController.text = _filter!;
  }

  void _onTextControllerChanged() {
    final filterHasChanged = _textController.text != _filter;
    if (!filterHasChanged) return;
    _filter = _textController.text;

    final search = _filter!.toLowerCase().trim();
    final filteredResult = _localizedToRailwayUndertaking
        .where((ruPair) => ruPair.$1.startsWith(search))
        .toList()
        .sortedWithSelectedFirst(_selectedRailwayUndertaking);

    _log.finer('Filtered RailwayUndertakings with $search to $filteredResult.');
    _rxAvailableRailwayUndertakings.add(filteredResult);
  }
}

extension on List<(String, RailwayUndertaking)> {
  List<RailwayUndertaking> sortedWithSelectedFirst(RailwayUndertaking selectedRailwayUndertaking) =>
      sortedBy((pair) => pair.$2 == selectedRailwayUndertaking ? '' : pair.$1).map((e) => e.$2).toList();
}
