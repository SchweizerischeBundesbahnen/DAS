import 'package:collection/collection.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/bracket_station_segment.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:das_client/sfera/src/mapper/mapper_utils.dart';
import 'package:das_client/sfera/src/mapper/segment_profile_mapper.dart';
import 'package:das_client/sfera/src/mapper/track_equipment_mapper.dart';
import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/related_train_information.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile_list.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:fimber/fimber.dart';

/// Used to map SFERA data to [Journey] with relevant [Metadata].
class SferaModelMapper {
  SferaModelMapper._();

  static Journey mapToJourney({
    required JourneyProfile journeyProfile,
    List<SegmentProfile> segmentProfiles = const [],
    List<TrainCharacteristics> trainCharacteristics = const [],
    RelatedTrainInformation? relatedTrainInformation,
    Journey? lastJourney,
  }) {
    try {
      return _mapToJourney(journeyProfile, segmentProfiles, trainCharacteristics, relatedTrainInformation, lastJourney);
    } catch (e, s) {
      Fimber.e('Error mapping journey-/segment profiles to journey:', ex: e, stacktrace: s);
      return Journey.invalid();
    }
  }

  static Journey _mapToJourney(
      JourneyProfile journeyProfile,
      List<SegmentProfile> segmentProfiles,
      List<TrainCharacteristics> trainCharacteristics,
      RelatedTrainInformation? relatedTrainInformation,
      Journey? lastJourney) {
    final journeyData = <BaseData>[];

    final segmentProfilesLists = journeyProfile.segmentProfilesLists.toList();

    final segmentJourneyData = segmentProfilesLists
        .mapIndexed((index, segmentProfileList) =>
            SegmentProfileMapper.parseSegmentProfile(segmentProfileList, index, segmentProfiles))
        .flattenedToList;
    journeyData.addAll(segmentJourneyData);

    final tramAreas = _parseTramAreas(segmentProfiles);
    journeyData.addAll(tramAreas);

    final additionalSpeedRestrictions = _parseAdditionalSpeedRestrictions(journeyProfile, segmentProfiles);
    for (final restriction in additionalSpeedRestrictions) {
      journeyData.add(AdditionalSpeedRestrictionData(
          restriction: restriction, order: restriction.orderFrom, kilometre: [restriction.kmFrom]));

      if (restriction.needsEndMarker(journeyData)) {
        journeyData.add(AdditionalSpeedRestrictionData(
            restriction: restriction, order: restriction.orderTo, kilometre: [restriction.kmTo]));
      }
    }

    final trackEquipmentSegments =
        TrackEquipmentMapper.parseNonStandardTrackEquipmentSegment(segmentProfilesLists, segmentProfiles);
    journeyData.addAll(_cabSignalingStart(trackEquipmentSegments));
    journeyData.addAll(_cabSignalingEnd(trackEquipmentSegments));

    journeyData.sort();

    final currentPosition =
        _calculateCurrentPosition(journeyData, segmentProfilesLists, relatedTrainInformation, lastJourney);
    final trainCharacteristic = _resolveFirstTrainCharacteristics(journeyProfile, trainCharacteristics);
    final servicePoints = journeyData.whereType<ServicePoint>();

    return Journey(
      metadata: Metadata(
        nextStop: _calculateNextStop(servicePoints, currentPosition),
        lastPosition: journeyData.firstWhereOrNull((it) => it.order == lastJourney?.metadata.currentPosition?.order),
        currentPosition: currentPosition,
        additionalSpeedRestrictions: additionalSpeedRestrictions,
        routeStart: journeyData.firstOrNull,
        routeEnd: journeyData.lastOrNull,
        delay: relatedTrainInformation?.ownTrain.trainLocationInformation.delay.delayAsDuration,
        nonStandardTrackEquipmentSegments: trackEquipmentSegments,
        bracketStationSegments: _parseBracketStationSegments(servicePoints),
        availableBreakSeries: _parseAvailableBreakSeries(journeyData),
        breakSeries: trainCharacteristic?.tcFeatures.trainCategoryCode != null &&
                trainCharacteristic?.tcFeatures.brakedWeightPercentage != null
            ? BreakSeries(
                trainSeries: trainCharacteristic!.tcFeatures.trainCategoryCode!,
                breakSeries: trainCharacteristic.tcFeatures.brakedWeightPercentage!)
            : null,
      ),
      data: journeyData,
    );
  }

  static BaseData? _calculateCurrentPosition(List<BaseData> journeyData, List<SegmentProfileList> segmentProfilesLists,
      RelatedTrainInformation? relatedTrainInformation, Journey? lastJourney) {
    final positionSpeed = relatedTrainInformation?.ownTrain.trainLocationInformation.positionSpeed;

    if (relatedTrainInformation == null || positionSpeed == null) {
      // Return first element as we have no information yet
      return journeyData.first;
    }

    final positionSegmentIndex = segmentProfilesLists.indexWhere((it) => it.spId == positionSpeed.spId);
    if (positionSegmentIndex == -1) {
      Fimber.w('Received position on unknown segment with spId: ${positionSpeed.spId}');
      return journeyData.firstWhereOrNull((it) => it.order == lastJourney?.metadata.currentPosition?.order);
    } else {
      final positionOrder = calculateOrder(positionSegmentIndex, positionSpeed.location);
      final currentPositionData = journeyData.lastWhereOrNull((it) => it.order <= positionOrder);
      return _adjustCurrentPositionToServicePoint(journeyData, currentPositionData ?? journeyData.first);
    }
  }

  static BaseData? _adjustCurrentPositionToServicePoint(List<BaseData> journeyData, BaseData currentPosition) {
    final positionIndex = journeyData.indexOf(currentPosition);
    if (journeyData.length > positionIndex + 1) {
      final nextData = journeyData[positionIndex + 1];
      if (nextData is ServicePoint) {
        return nextData;
      }
    }

    return currentPosition;
  }

  static ServicePoint? _calculateNextStop(Iterable<ServicePoint> servicePoints, BaseData? currentPosition) {
    return servicePoints.skip(1).firstWhereOrNull(
            (data) => data.isStop && (currentPosition == null || data.order > currentPosition.order)) ??
        servicePoints.last;
  }

  static List<AdditionalSpeedRestriction> _parseAdditionalSpeedRestrictions(
      JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles) {
    final List<AdditionalSpeedRestriction> result = [];
    final now = DateTime.now();
    final segmentProfilesLists = journeyProfile.segmentProfilesLists.toList();

    int? startSegmentIndex;
    int? endSegmentIndex;
    double? startLocation;
    double? endLocation;

    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfileList = segmentProfilesLists[segmentIndex];

      for (final asrTemporaryConstrain in segmentProfileList.asrTemporaryConstrains) {
        // TODO: Es werden Langsamfahrstellen von 30min vor Start der Fahrt (betriebliche Zeit) bis 30min nach Ende der Fahrt (betriebliche Zeit) angezeigt.
        if (asrTemporaryConstrain.startTime != null && asrTemporaryConstrain.startTime!.isAfter(now) ||
            asrTemporaryConstrain.endTime != null && asrTemporaryConstrain.endTime!.isBefore(now)) {
          continue;
        }

        switch (asrTemporaryConstrain.startEndQualifier) {
          case StartEndQualifier.starts:
            startLocation = asrTemporaryConstrain.startLocation;
            startSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.startsEnds:
            startLocation = asrTemporaryConstrain.startLocation;
            startSegmentIndex = segmentIndex;
            continue next;
          next:
          case StartEndQualifier.ends:
            endLocation = asrTemporaryConstrain.endLocation;
            endSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.wholeSp:
            break;
        }

        if (startSegmentIndex != null && endSegmentIndex != null && startLocation != null && endLocation != null) {
          final startSegment = segmentProfiles.firstMatch(segmentProfilesLists[startSegmentIndex]);
          final endSegment = segmentProfiles.firstMatch(segmentProfilesLists[endSegmentIndex]);

          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);

          final startOrder = calculateOrder(startSegmentIndex, startLocation);
          final endOrder = calculateOrder(endSegmentIndex, endLocation);

          result.add(AdditionalSpeedRestriction(
              kmFrom: startKilometreMap[startLocation]!.first,
              kmTo: endKilometreMap[endLocation]!.first,
              orderFrom: startOrder,
              orderTo: endOrder,
              speed: asrTemporaryConstrain.additionalSpeedRestriction?.asrSpeed));

          startSegmentIndex = null;
          endSegmentIndex = null;
          startLocation = null;
          endLocation = null;
        }
      }
    }

    if (startSegmentIndex != null || endSegmentIndex != null || startLocation != null || endLocation != null) {
      Fimber.w('Incomplete additional speed restriction found: '
          'startSegmentIndex: $startSegmentIndex, endSegmentIndex: $endSegmentIndex, '
          'startLocation: $startLocation, endLocation: $endLocation');
    }

    return result;
  }

  static Iterable<CABSignaling> _cabSignalingStart(Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    return trackEquipmentSegments.withCABSignalingStart
        .map((element) => CABSignaling(isStart: true, order: element.startOrder!, kilometre: element.startKm));
  }

  static Iterable<CABSignaling> _cabSignalingEnd(Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    return trackEquipmentSegments.withCABSignalingEnd
        .map((element) => CABSignaling(isStart: false, order: element.endOrder!, kilometre: element.endKm));
  }

  static Set<BreakSeries> _parseAvailableBreakSeries(List<BaseData> journeyData) {
    return journeyData
        .expand((it) => [...it.speedData?.speeds ?? [], ...it.localSpeedData?.speeds ?? []])
        .where((it) => it.breakSeries != null)
        .map((it) => BreakSeries(trainSeries: it.trainSeries, breakSeries: it.breakSeries!))
        .toSet();
  }

  static TrainCharacteristics? _resolveFirstTrainCharacteristics(
      JourneyProfile journey, List<TrainCharacteristics> trainCharacteristics) {
    final firstTrainRef = journey.trainCharactericsRefSet.firstOrNull;
    if (firstTrainRef == null) return null;

    return trainCharacteristics.firstWhereOrNull((it) =>
        it.tcId == firstTrainRef.tcId &&
        it.ruId == firstTrainRef.ruId &&
        it.versionMajor == firstTrainRef.versionMajor &&
        it.versionMinor == firstTrainRef.versionMinor);
  }

  static List<TramArea> _parseTramAreas(List<SegmentProfile> segmentProfiles) {
    final List<TramArea> result = [];

    int? startSegmentIndex;
    int? endSegmentIndex;
    double? startLocation;
    double? endLocation;
    int? amountTramSignals;

    for (int segmentIndex = 0; segmentIndex < segmentProfiles.length; segmentIndex++) {
      final segmentProfile = segmentProfiles[segmentIndex];

      if (segmentProfile.areas == null) continue;

      for (final tramArea in segmentProfile.areas!.tramAreas) {
        switch (tramArea.startEndQualifier) {
          case StartEndQualifier.starts:
            startLocation = tramArea.startLocation;
            startSegmentIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            break;
          case StartEndQualifier.startsEnds:
            startLocation = tramArea.startLocation;
            startSegmentIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            continue next;
          next:
          case StartEndQualifier.ends:
            endLocation = tramArea.endLocation;
            endSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.wholeSp:
            break;
          case null:
            Fimber.w('Received tramArea with startEndQualifier=null');
            break;
        }

        if (startSegmentIndex != null &&
            endSegmentIndex != null &&
            startLocation != null &&
            endLocation != null &&
            amountTramSignals != null) {
          final startSegment = segmentProfiles[startSegmentIndex];
          final endSegment = segmentProfiles[endSegmentIndex];

          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);

          result.add(TramArea(
            order: calculateOrder(startSegmentIndex, startLocation),
            kilometre: startKilometreMap[startLocation]!,
            endKilometre: endKilometreMap[endLocation]!.first,
            amountTramSignals: amountTramSignals,
          ));

          startSegmentIndex = null;
          endSegmentIndex = null;
          startLocation = null;
          endLocation = null;
          amountTramSignals = null;
        }
      }
    }

    if (startSegmentIndex != null || endSegmentIndex != null || startLocation != null || endLocation != null) {
      Fimber.w('Incomplete tram area found: '
          'startSegmentIndex: $startSegmentIndex, endSegmentIndex: $endSegmentIndex, '
          'startLocation: $startLocation, endLocation: $endLocation, amountTramSignals: $amountTramSignals');
    }

    return result;
  }

  static List<BracketStationSegment> _parseBracketStationSegments(Iterable<ServicePoint> servicePoints) {
    final Map<BracketMainStation, List<ServicePoint>> combinedBracketStations = {};

    for (final servicePoint in servicePoints) {
      final mainStation = servicePoint.bracketMainStation;
      if (mainStation != null) {
        if (!combinedBracketStations.containsKey(mainStation)) {
          combinedBracketStations[mainStation] = [];
        }
        combinedBracketStations[mainStation]!.add(servicePoint);
      }
    }

    return combinedBracketStations.values.map((bracketStations) {
      if (bracketStations.length < 2) {
        Fimber.w('There should at least be two bracket stations for a segment. Found service points: $bracketStations');
      }

      final orders = bracketStations.map((it) => it.order);
      return BracketStationSegment(
        mainStationAbbreviation: bracketStations.first.bracketMainStation!.abbreviation,
        startOrder: orders.min,
        endOrder: orders.max,
      );
    }).toList();
  }
}
