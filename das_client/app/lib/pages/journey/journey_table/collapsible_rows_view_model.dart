import 'dart:async';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

enum CollapsedState {
  collapsed,
  expandedWithCollapsedContent,
  expanded;

  static CollapsedState defaultOf(BaseData data) =>
      data is UncodedOperationalIndication ? CollapsedState.expandedWithCollapsedContent : CollapsedState.expanded;
}

class CollapsibleRowsViewModel {
  CollapsibleRowsViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel> journeyPositionStream,
  }) {
    _init(journeyStream, journeyPositionStream);
  }

  Stream<Map<int, CollapsedState>> get collapsedRows => _rxCollapsedRows.stream;

  Map<int, CollapsedState> get collapsedRowsValue => _rxCollapsedRows.value;

  final _rxCollapsedRows = BehaviorSubject<Map<int, CollapsedState>>.seeded({});

  StreamSubscription<(Journey?, JourneyPositionModel)>? _journeySubscription;

  void _init(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> journeyPositionStream) {
    _journeySubscription?.cancel();
    _journeySubscription =
        CombineLatestStream.combine2(
          journeyStream,
          journeyPositionStream,
          (a, b) => (a, b),
        ).listen((data) {
          if (data.$1 != null) {
            _collapsePassedAccordionRows(data.$1!, data.$2);
          }
        });
  }

  void toggleRow(BaseData data, {bool isContentExpandable = false}) {
    final newMap = Map<int, CollapsedState>.from(_rxCollapsedRows.value);
    final currentState = newMap.stateOf(data);
    if (currentState == CollapsedState.collapsed) {
      newMap[data.hashCode] = CollapsedState.defaultOf(data);
    } else if (currentState == CollapsedState.expandedWithCollapsedContent && isContentExpandable) {
      newMap[data.hashCode] = CollapsedState.expanded;
    } else {
      newMap[data.hashCode] = CollapsedState.collapsed;
    }

    _rxCollapsedRows.add(newMap);
  }

  void _collapsePassedAccordionRows(Journey journey, JourneyPositionModel journeyPosition) {
    final currentPosition = journeyPosition.currentPosition;
    final lastPosition = journeyPosition.lastPosition;
    if (currentPosition == lastPosition || lastPosition == null || currentPosition == null) {
      return;
    }

    final fromIndex = journey.data.indexOf(lastPosition);
    final toIndex = journey.data.indexOf(currentPosition);
    if (fromIndex > toIndex || fromIndex == -1 || toIndex == -1) return;

    final passedCollapsibleData = journey.data.sublist(fromIndex, toIndex).where((data) => data.isCollapsible);

    final collapsedRows = _rxCollapsedRows.value;
    final newMap = Map.of(collapsedRows);
    for (final data in passedCollapsibleData) {
      final current = collapsedRows[data.hashCode];
      if (current != null && current == CollapsedState.collapsed) continue;

      if (journey.data.lastIndexWhere((it) => it.isCollapsible && it.hashCode == data.hashCode) <= toIndex) {
        newMap[data.hashCode] = CollapsedState.collapsed;
      }
    }

    if (newMap.length != collapsedRows.length) {
      _rxCollapsedRows.add(newMap);
    }
  }

  void dispose() {
    _journeySubscription?.cancel();
    _rxCollapsedRows.close();
  }
}

extension BaseDataExtension on BaseData {
  bool get isCollapsible => this is BaseFootNote || this is UncodedOperationalIndication;
}

extension CollapsedStateMap on Map<int, CollapsedState> {
  CollapsedState stateOf(BaseData data) => this[data.hashCode] ?? CollapsedState.defaultOf(data);
}
