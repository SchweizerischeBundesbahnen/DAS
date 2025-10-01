import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyRailwayUndertakingFilterController');

/// This controller is responsible for filtering **localized** names of railway undertakings.
/// Thus it must access the AppLocalizations.
///
/// It exposes and manipulates TextController for the corresponding (filter) text field.
/// It takes a FocusNode to manage the state if Focus is lost without selecting a different railway undertaking.
/// It has a setter for the currently selected RailwayUndertaking.
/// It updates the availableRailwayUndertakings for selection in the ViewModel to display them in a different
/// widget.
///
/// This class primarily allows to prevent the AppLocalization and FocusNode from leaking into the ViewModel.
class JourneyRailwayUndertakingFilterController {
  JourneyRailwayUndertakingFilterController({
    required this.localizations,
    required FocusNode focusNode,
    required this.updateAvailableRailwayUndertakings,
    required RailwayUndertaking initialRailwayUndertaking,
  }) {
    _selectedRailwayUndertaking = initialRailwayUndertaking;
    _initFocusNodeListener(focusNode);
    _initTextEditingController(_selectedRailwayUndertaking);
    _initRuToLocalizedMap();
  }

  final AppLocalizations localizations;
  final void Function(List<RailwayUndertaking>) updateAvailableRailwayUndertakings;

  late FocusNode _focusNode;
  bool _hasFocus = false;

  late TextEditingController _textController;
  late RailwayUndertaking _selectedRailwayUndertaking;
  late List<(String, RailwayUndertaking)> _localizedToRailwayUndertaking;

  TextEditingController get textEditingController => _textController;

  // for testing convenience
  @visibleForTesting
  String? get filterValue => _textController.text;

  set selectedRailwayUndertaking(RailwayUndertaking selectedRailwayUndertaking) {
    _selectedRailwayUndertaking = selectedRailwayUndertaking;
    _resetToSelectedRailwayUndertaking();
  }

  void dispose() {
    _focusNode.removeListener(_reactToFocusChanges);
    _textController.removeListener(_filterAvailableRailwayUndertakings);
    _textController.dispose();
  }

  void _initFocusNodeListener(FocusNode focusNode) {
    _focusNode = focusNode;
    focusNode.addListener(_reactToFocusChanges);
  }

  void _initTextEditingController(RailwayUndertaking? selectedRailwayUndertaking) {
    _textController = TextEditingController(text: selectedRailwayUndertaking?.localizedText(localizations));
    _textController.addListener(_filterAvailableRailwayUndertakings);
  }

  void _initRuToLocalizedMap() {
    _localizedToRailwayUndertaking = RailwayUndertaking.values
        .map((ru) => (ru.localizedText(localizations).toLowerCase().trim(), ru))
        .sorted((a, b) => a.$1.compareTo(b.$1));
  }

  void _reactToFocusChanges() {
    final lostFocus = !_focusNode.hasFocus && _hasFocus;
    final gainedFocus = _focusNode.hasFocus && !_hasFocus;
    _hasFocus = _focusNode.hasFocus;

    if (gainedFocus) _filterAvailableRailwayUndertakings();
    if (lostFocus) _resetToSelectedRailwayUndertaking();
  }

  void _resetToSelectedRailwayUndertaking() {
    _textController.text = _selectedRailwayUndertaking.localizedText(localizations);
  }

  void _filterAvailableRailwayUndertakings() {
    final filter = _textController.text.toLowerCase().trim();

    final filteredResult = _localizedToRailwayUndertaking
        .where((ruPair) => ruPair.$1.startsWith(filter))
        .map((e) => e.$2)
        .toList();

    _log.finer('Filtered RailwayUndertakings with $filter to $filteredResult.');
    updateAvailableRailwayUndertakings.call(filteredResult);
  }
}
