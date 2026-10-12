import 'dart:collection';

import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/journey_screen/view_model/switchback_annotation.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

extension BaseDataX on Iterable<BaseData> {
  Iterable<BaseData> addTrainDriverTurnoverRows(ExtendedTrainIdentification? trainIdentification) {
    if (trainIdentification == null) return this;

    final startLocation = trainIdentification.tafTapLocationReferenceStart;
    final endLocation = trainIdentification.tafTapLocationReferenceEnd;

    if (startLocation == null && endLocation == null) return this;

    final servicePoints = whereType<ServicePoint>();
    final firstServicePoint = servicePoints.firstOrNull;
    final lastServicePoint = servicePoints.lastOrNull;

    final List<BaseData> resultList = toList();

    TrainDriverTurnover? endTrainDriverTurnover;
    TrainDriverTurnover? startTrainDriverTurnover;

    for (final data in servicePoints) {
      if (data == firstServicePoint || data == lastServicePoint) continue;

      if (startTrainDriverTurnover == null && startLocation != null && startLocation == data.locationCode) {
        startTrainDriverTurnover = TrainDriverTurnover(order: data.order, isStart: true);
      } else if (endLocation != null && endLocation == data.locationCode) {
        endTrainDriverTurnover = TrainDriverTurnover(order: data.order, isStart: false);
      }
    }

    if (startTrainDriverTurnover != null) {
      resultList.add(startTrainDriverTurnover);
    }

    if (endTrainDriverTurnover != null) {
      resultList.add(endTrainDriverTurnover);
    }

    return resultList;
  }

  Iterable<BaseData> hideSignals({
    required bool stationSignals,
    required bool conventionalSpeedSignals,
    required bool extendedSpeedSignals,
    required List<NonStandardTrackEquipmentSegment> nonStandardTrackEquipmentSegments,
  }) {
    return where((data) {
      if (data is! Signal) return true;

      final ignoreEtcsStopSignForChecks =
          (conventionalSpeedSignals &&
              nonStandardTrackEquipmentSegments.isInEtcsLevel2ConventionalSpeedSegment(data.order)) ||
          (extendedSpeedSignals && nonStandardTrackEquipmentSegments.isInEtcsLevel2ExtendedSpeedSegment(data.order));

      final signalFunctions = ignoreEtcsStopSignForChecks
          ? data.functions.whereNot((it) => it == .etcsStopSign)
          : data.functions;

      if (signalFunctions.isEmpty) return false;
      if (!stationSignals) return true;

      return !signalFunctions.every(
        (it) => <SignalFunction>[.entry, .exit, .intermediate, .trackEndSignal].contains(it),
      );
    });
  }

  /// removes all additional service points that are not at the route start/end and have no speed change and are not a stop.
  Iterable<BaseData> removeIrrelevantServicePoints(SplayTreeMap<int, SingleSpeed?> calculatedSpeeds) {
    final servicePoints = whereType<ServicePoint>().toList()..sort();
    return whereNot((data) {
      final isNotStartOrEndServicePoint = data != servicePoints.first && data != servicePoints.last;
      return data is ServicePoint &&
          data.isAdditional &&
          isNotStartOrEndServicePoint &&
          calculatedSpeeds[data.order] == null &&
          !data.isStop;
    });
  }

  Iterable<BaseData> hideIndicationsForHiddenServicePoint() {
    final List<BaseData> resultList = toList();
    for (final data in this) {
      if (data is OperationalIndication || data is RuIndication) {
        final servicePoint = resultList.firstWhereOrNull(
          (it) => it is ServicePoint && it.order == data.order,
        );
        if (servicePoint == null) {
          resultList.remove(data);
        }
      }
    }

    return resultList;
  }

  Iterable<BaseData> hideAcknowledgedDeletedRows(
    Set<Modification> acknowledgedModifications,
    JourneySettings settings,
  ) {
    if (settings.showAcknowledgedModifications) return this;

    return where((data) {
      if (data is! JourneyPoint) return true;

      final modification = data.modification;
      if (modification == null || modification.type != .deleted) return true;

      return !acknowledgedModifications.contains(modification);
    });
  }

  Iterable<BaseData> addSwitchbackRows(Map<ServicePoint, SwitchbackStation> switchbackStationMap) {
    if (switchbackStationMap.isEmpty) return this;

    final List<BaseData> resultList = toList();

    for (final it in switchbackStationMap.entries) {
      final switchbackStation = it.value;
      if (switchbackStation.isArrival) {
        final arrivalOrder = switchbackStation.station.order;
        final departureOrder = switchbackStation.counterpartStation.order;

        // Place in the middle between the 2 stations
        final switchbackOrder = ((arrivalOrder + departureOrder) / 2).toInt();
        resultList.add(SwitchbackAnnotation(order: switchbackOrder));
      }
    }

    return resultList;
  }

  Iterable<BaseData> hideJourneyAnnotationsOnSwitchbackStations(
    Map<ServicePoint, SwitchbackStation> switchbackStationMap,
  ) {
    if (switchbackStationMap.isEmpty) return this;

    final List<BaseData> resultList = toList();

    final arrivalStationsOrders = switchbackStationMap.values
        .where((it) => it.isArrival)
        .map((it) => it.station.order)
        .toSet();
    final departureStationsOrders = switchbackStationMap.values
        .where((it) => it.isDeparture)
        .map((it) => it.station.order)
        .toSet();

    final indications = where(
      (item) => item is OperationalIndication || item is RuIndication || item is PersonalNoteAnnotation,
    );
    for (final item in indications) {
      if (departureStationsOrders.contains(item.order)) {
        resultList.remove(item);
      }
    }

    final radnFootNotes = where((item) => item is OpFootNote || item is LineFootNote);
    for (final item in radnFootNotes) {
      if (arrivalStationsOrders.contains(item.order)) {
        resultList.remove(item);
      }
    }

    return resultList;
  }
}
