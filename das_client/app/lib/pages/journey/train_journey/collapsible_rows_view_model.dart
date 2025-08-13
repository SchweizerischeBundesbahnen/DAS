import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

enum CollapsedState { collapsed, openWithCollapsedContent }

class CollapsibleRowsViewModel {
  CollapsibleRowsViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _init();
  }

  Stream<Map<int, CollapsedState>> get collapsedRows => _rxCollapsedRows.stream;

  Map<int, CollapsedState> get collapsedRowsValue => _rxCollapsedRows.value;

  final _rxCollapsedRows = BehaviorSubject<Map<int, CollapsedState>>.seeded({});

  final SferaRemoteRepo _sferaRemoteRepo;

  final _subscriptions = <StreamSubscription>[];
  StreamSubscription? _journeySubscription;

  void _init() {
    _listenToSferaRemoteRepo();
  }

  void toggleRow(BaseData data) {
    final newMap = Map<int, CollapsedState>.from(_rxCollapsedRows.value);
    if (!newMap.isExpanded(data.hashCode)) {
      newMap.remove(data.hashCode);
    } else {
      newMap[data.hashCode] = CollapsedState.collapsed;
    }

    _rxCollapsedRows.add(newMap);
  }

  void openWithCollapsedContent(BaseData data) {
    final newMap = Map<int, CollapsedState>.from(_rxCollapsedRows.value);
    newMap[data.hashCode] = CollapsedState.openWithCollapsedContent;
    _rxCollapsedRows.add(newMap);
  }

  void _listenToSferaRemoteRepo() {
    final subscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          _listenToJourneyUpdates();
          break;
        case SferaRemoteRepositoryState.connecting:
          break;
        case SferaRemoteRepositoryState.disconnected:
          if (_sferaRemoteRepo.lastError != null) {
            _journeySubscription?.cancel();
            break;
          }
      }
    });
    _subscriptions.add(subscription);
  }

  void _listenToJourneyUpdates() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaRemoteRepo.journeyStream.listen((journey) {
      if (journey != null) {
        _collapsePassedAccordionRows(journey);
      }
    });
  }

  void _collapsePassedAccordionRows(Journey journey) {
    final currentPosition = journey.metadata.currentPosition;
    final lastPosition = journey.metadata.lastPosition;
    if (currentPosition == lastPosition || lastPosition == null || currentPosition == null) {
      return;
    }

    final fromIndex = journey.data.indexOf(lastPosition);
    final toIndex = journey.data.indexOf(currentPosition);
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
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _journeySubscription?.cancel();
  }
}

// extension

extension BaseDataExtension on BaseData {
  bool get isCollapsible => this is BaseFootNote || this is UncodedOperationalIndication;
}

extension CollapsedStateMap on Map<int, CollapsedState> {
  bool isContentExpanded(int key) => this[key] == CollapsedState.openWithCollapsedContent;

  bool isExpanded(int key) => !containsKey(key) || this[key] == CollapsedState.openWithCollapsedContent;
}
