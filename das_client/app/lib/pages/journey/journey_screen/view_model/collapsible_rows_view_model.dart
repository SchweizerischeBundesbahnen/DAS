import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

enum CollapsedState {
  collapsed,
  expandedWithCollapsedContent,
  expanded;

  static CollapsedState defaultOf(BaseData? data) =>
      data is OperationalIndication || data is RuIndication ? .expandedWithCollapsedContent : .expanded;
}

class CollapsibleRowsViewModel extends JourneyAwareViewModel {
  CollapsibleRowsViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    required this._simTrainViewModel,
    super.journeyViewModel,
  }) {
    _init(journeyViewModel.journey, journeyPositionStream);
  }

  final SimTrainViewModel _simTrainViewModel;
  final _rxCollapsedRows = BehaviorSubject<Map<int, CollapsedState>>.seeded({});

  StreamSubscription<(Journey?, JourneyPositionModel)>? _journeySubscription;
  StreamSubscription<bool>? _simTrainSubscription;

  Stream<Map<int, CollapsedState>> get collapsedRows => _rxCollapsedRows.stream;

  Map<int, CollapsedState> get collapsedRowsValue => _rxCollapsedRows.value;

  void toggleRow(BaseData data, {bool isContentExpandable = false}) {
    final newMap = Map<int, CollapsedState>.from(_rxCollapsedRows.value);
    final currentState = newMap.stateOf(data);
    if (currentState == .collapsed) {
      newMap[data.hashCode] = .defaultOf(data);
    } else if (currentState == .expandedWithCollapsedContent && isContentExpandable) {
      newMap[data.hashCode] = .expanded;
    } else {
      newMap[data.hashCode] = .collapsed;
    }

    _rxCollapsedRows.add(newMap);
  }

  void _init(
    Stream<Journey?> journeyStream,
    Stream<JourneyPositionModel> journeyPositionStream,
  ) {
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

    _simTrainSubscription?.cancel();
    _simTrainSubscription = _simTrainViewModel.isSimTrain.listen((_) {
      _updateSimFootNotes(lastJourney);
    });
  }

  void _updateSimFootNotes(Journey? journey) {
    if (journey == null) return;

    final simFootNotes = journey.data.whereType<BaseFootNote>().where((fn) => fn.footNote.isSIM).toList();
    if (simFootNotes.isEmpty) return;

    final isSimTrain = _simTrainViewModel.isSimTrainValue;
    final newMap = Map<int, CollapsedState>.from(_rxCollapsedRows.value);
    for (final fn in simFootNotes) {
      newMap[fn.hashCode] = isSimTrain ? CollapsedState.expanded : CollapsedState.collapsed;
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

    final isSimTrain = _simTrainViewModel.isSimTrainValue;
    final collapsedRows = _rxCollapsedRows.value;
    final newMap = Map.of(collapsedRows);
    for (final data in passedCollapsibleData) {
      final current = collapsedRows[data.hashCode];
      if (current != null && current == .collapsed) continue;

      // Do not auto-collapse SIM foot notes when this is a SIM train
      if (isSimTrain && data is BaseFootNote && data.footNote.isSIM) continue;

      if (journey.data.lastIndexWhere((it) => it.isCollapsible && it.hashCode == data.hashCode) <= toIndex) {
        newMap[data.hashCode] = .collapsed;
      }
    }

    if (newMap.length != collapsedRows.length) {
      _rxCollapsedRows.add(newMap);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _journeySubscription?.cancel();
    _simTrainSubscription?.cancel();
    _rxCollapsedRows.close();
  }

  @override
  void onJourneyChanged(journey) {
    _rxCollapsedRows.add({});
    _updateSimFootNotes(journey);
  }
}

extension BaseDataX on BaseData {
  bool get isCollapsible => this is BaseFootNote || this is OperationalIndication || this is RuIndication;
}

extension CollapsedStateMapX on Map<int, CollapsedState> {
  CollapsedState stateOf(BaseData? data) => this[data.hashCode] ?? .defaultOf(data);

  Map<int, CollapsedState> whereContains(Iterable<BaseData> data) {
    final hashCodes = data.map((d) => d.hashCode).toSet();
    return Map<int, CollapsedState>.fromEntries(entries.where((entry) => hashCodes.contains(entry.key)));
  }
}
