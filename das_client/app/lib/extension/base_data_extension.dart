import 'dart:collection';

import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
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

    for (final data in this) {
      if (data == firstServicePoint || data == lastServicePoint) continue;

      if (data is ServicePoint) {
        if (startLocation != null && startLocation == data.locationCode) {
          resultList.add(TrainDriverTurnover(order: data.order, isStart: true));
        } else if (endLocation != null && endLocation == data.locationCode) {
          resultList.add(TrainDriverTurnover(order: data.order, isStart: false));
        }
      }
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
}
