import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/enums/operational_indication_type_dto.dart';
import 'package:sfera/src/data/dto/enums/start_end_qualifier_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/multilingual_text_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_nsp_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/mapper_utils.dart';
import 'package:sfera/src/data/mapper/segment_profile_mapper.dart';
import 'package:sfera/src/data/mapper/speed_mapper.dart';
import 'package:sfera/src/data/mapper/track_equipment_mapper.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';

final _log = Logger('SferaModelMapper');

/// Used to map SFERA data to [Journey] with relevant [Metadata].
class SferaModelMapper {
  SferaModelMapper._();

  static Journey mapToJourney({
    required JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles = const [],
    List<TrainCharacteristicsDto> trainCharacteristics = const [],
    RelatedTrainInformationDto? relatedTrainInformation,
    Journey? lastJourney,
  }) {
    try {
      return _tryMapToJourney(
        journeyProfile,
        segmentProfiles,
        trainCharacteristics,
        relatedTrainInformation,
        lastJourney,
      );
    } catch (e, s) {
      _log.severe('Error mapping journey-/segment profiles to journey:', e, s);
      return Journey.invalid();
    }
  }

  static Journey _tryMapToJourney(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
    List<TrainCharacteristicsDto> trainCharacteristics,
    RelatedTrainInformationDto? relatedTrainInformation,
    Journey? lastJourney,
  ) {
    final journeyData = <BaseData>[];

    final segmentProfileReferences = journeyProfile.segmentProfileReferences.toList();

    final segmentJourneyData = segmentProfileReferences
        .mapIndexed((index, reference) => SegmentProfileMapper.parseSegmentProfile(reference, index, segmentProfiles))
        .flattenedToList;
    journeyData.addAll(segmentJourneyData);

    final uncodedOperationalIndications = segmentProfileReferences
        .mapIndexed((index, reference) => _parseUncodedOperationalIndication(index, reference))
        .flattenedToList;
    journeyData.addAll(uncodedOperationalIndications);

    final tramAreas = _parseTramAreas(segmentProfiles);
    journeyData.addAll(tramAreas);

    final trackEquipmentSegments = TrackEquipmentMapper.parseSegments(segmentProfileReferences, segmentProfiles);
    journeyData.addAll(_cabSignalingStart(trackEquipmentSegments));
    journeyData.addAll(_cabSignalingEnd(trackEquipmentSegments, journeyData));

    final servicePoints = journeyData.whereType<ServicePoint>().sortedBy((sP) => sP.order);

    final additionalSpeedRestrictions = _parseAdditionalSpeedRestrictions(
      journeyProfile,
      segmentProfiles,
      servicePoints,
    );
    final displayedSpeedRestrictions = additionalSpeedRestrictions
        .where((asr) => asr.isDisplayed(trackEquipmentSegments))
        .toList();
    final consolidatedASRs = _consolidateAdditionalSpeedRestrictions(journeyData, displayedSpeedRestrictions);
    journeyData.addAll(consolidatedASRs);

    journeyData.sort();

    final currentPosition = _calculateCurrentPosition(
      journeyData,
      segmentProfileReferences,
      relatedTrainInformation,
      lastJourney,
    );
    final trainCharacteristic = _resolveFirstTrainCharacteristics(journeyProfile, trainCharacteristics);

    return Journey(
      metadata: Metadata(
        nextStop: _calculateNextStop(servicePoints, currentPosition),
        lastPosition: journeyData.firstWhereOrNull((it) => it.order == lastJourney?.metadata.currentPosition?.order),
        lastServicePoint: _calculateLastServicePoint(servicePoints, currentPosition),
        currentPosition: currentPosition,
        additionalSpeedRestrictions: additionalSpeedRestrictions,
        routeStart: journeyData.firstOrNull,
        routeEnd: journeyData.lastOrNull,
        delay: _parseDelay(relatedTrainInformation),
        anyOperationalArrivalDepartureTimes: servicePoints.any(
          (sP) => sP.arrivalDepartureTime?.hasAnyOperationalTime ?? false,
        ),
        nonStandardTrackEquipmentSegments: trackEquipmentSegments,
        bracketStationSegments: _parseBracketStationSegments(servicePoints),
        advisedSpeedSegments: SpeedMapper.advisedSpeeds(journeyProfile, segmentProfiles, journeyData),
        availableBreakSeries: _parseAvailableBreakSeries(journeyData),
        communicationNetworkChanges: _parseCommunicationNetworkChanges(segmentProfileReferences, segmentProfiles),
        breakSeries:
            trainCharacteristic?.tcFeatures.trainCategoryCode != null &&
                trainCharacteristic?.tcFeatures.brakedWeightPercentage != null
            ? BreakSeries(
                trainSeries: trainCharacteristic!.tcFeatures.trainCategoryCode!,
                breakSeries: trainCharacteristic.tcFeatures.brakedWeightPercentage!,
              )
            : null,
        lineFootNoteLocations: _generateLineFootNoteLocationMap(journeyData.whereType<LineFootNote>()),
        radioContactLists: _parseContactLists(segmentProfileReferences, segmentProfiles),
        lineSpeeds: _gatherLineSpeeds(journeyData),
        calculatedSpeeds: _gatherCalculatedSpeeds(journeyData),
      ),
      data: journeyData,
    );
  }

  static BaseData? _calculateCurrentPosition(
    List<BaseData> journeyData,
    List<SegmentProfileReferenceDto> segmentProfilesLists,
    RelatedTrainInformationDto? relatedTrainInformation,
    Journey? lastJourney,
  ) {
    final positionSpeed = relatedTrainInformation?.ownTrain.trainLocationInformation.positionSpeed;

    if (relatedTrainInformation == null || positionSpeed == null) {
      // Return first element as we have no information yet
      return journeyData.first;
    }

    final positionSegmentIndex = segmentProfilesLists.indexWhere((it) => it.spId == positionSpeed.spId);
    if (positionSegmentIndex == -1) {
      _log.warning('Received position on unknown segment with spId: ${positionSpeed.spId}');
      return journeyData.firstWhereOrNull((it) => it.order == lastJourney?.metadata.currentPosition?.order);
    } else {
      final positionOrder = calculateOrder(positionSegmentIndex, positionSpeed.location);
      final currentPositionData = journeyData.lastWhereOrNull((it) => it.order <= positionOrder && it is! BaseFootNote);
      return _adjustCurrentPositionToServicePoint(journeyData, currentPositionData ?? journeyData.first);
    }
  }

  /// returns element at next position, if it is a [ServicePoint] and the current position is not already one.
  static BaseData? _adjustCurrentPositionToServicePoint(List<BaseData> journeyData, BaseData currentPosition) {
    final positionIndex = journeyData.indexOf(currentPosition);
    if (currentPosition is ServicePoint) {
      return currentPosition;
    }

    if (journeyData.length > positionIndex + 1) {
      final nextData = journeyData[positionIndex + 1];
      if (nextData is ServicePoint) {
        return nextData;
      }
    }

    return currentPosition;
  }

  static ServicePoint? _calculateNextStop(Iterable<ServicePoint> servicePoints, BaseData? currentPosition) {
    return servicePoints
            .skip(1)
            .firstWhereOrNull((sP) => sP.isStop && (currentPosition == null || sP.order > currentPosition.order)) ??
        servicePoints.last;
  }

  static ServicePoint? _calculateLastServicePoint(Iterable<ServicePoint> servicePoints, BaseData? currentPosition) {
    if (currentPosition == null) return servicePoints.firstOrNull;

    return servicePoints.toList().reversed.firstWhereOrNull((sP) => sP.order <= currentPosition.order);
  }

  static List<AdditionalSpeedRestrictionData> _consolidateAdditionalSpeedRestrictions(
    List<BaseData> journeyData,
    List<AdditionalSpeedRestriction> restrictions,
  ) {
    if (restrictions.isEmpty) return [];

    restrictions.sort((a, b) => a.orderFrom.compareTo(b.orderFrom));

    final List<List<AdditionalSpeedRestriction>> grouped = [];
    var currentGroup = [restrictions.first];

    for (int i = 1; i < restrictions.length; i++) {
      final current = restrictions[i];
      final lastInGroup = currentGroup.getHighestByOrderTo;

      if (current.orderFrom <= lastInGroup.orderTo) {
        currentGroup.add(current);
      } else {
        grouped.add(currentGroup);
        currentGroup = [current];
      }
    }
    grouped.add(currentGroup);

    final result = <AdditionalSpeedRestrictionData>[];
    for (final group in grouped) {
      result.add(AdditionalSpeedRestrictionData.start(group));
      if (group.any((restriction) => restriction.needsEndMarker(journeyData))) {
        result.add(AdditionalSpeedRestrictionData.end(group));
      }
    }
    return result;
  }

  static List<AdditionalSpeedRestriction> _parseAdditionalSpeedRestrictions(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
    List<ServicePoint> servicePoints,
  ) {
    final List<AdditionalSpeedRestriction> result = [];
    final segmentProfilesReferences = journeyProfile.segmentProfileReferences.toList();

    final Map<String?, _SegmentMapperData> segmentsData = {};

    for (int segmentIndex = 0; segmentIndex < segmentProfilesReferences.length; segmentIndex++) {
      final segmentProfileReference = segmentProfilesReferences[segmentIndex];

      for (final asrTemporaryConstrain in segmentProfileReference.asrTemporaryConstraints) {
        if (_shouldSkipAsrDueToJourneyTimes(servicePoints, asrTemporaryConstrain)) continue;

        final parallelAsrId = asrTemporaryConstrain.parallelAsrConstraintDto?.idNsp.id;
        segmentsData.putIfAbsent(parallelAsrId, () => _SegmentMapperData());
        final segmentData = segmentsData[parallelAsrId]!;

        switch (asrTemporaryConstrain.startEndQualifier) {
          case StartEndQualifierDto.starts:
            segmentData.startLocation = asrTemporaryConstrain.startLocation;
            segmentData.startIndex = segmentIndex;
            break;
          case StartEndQualifierDto.startsEnds:
            segmentData.startLocation = asrTemporaryConstrain.startLocation;
            segmentData.startIndex = segmentIndex;
            continue next;
          next:
          case StartEndQualifierDto.ends:
            segmentData.endLocation = asrTemporaryConstrain.endLocation;
            segmentData.endIndex = segmentIndex;
            break;
          case StartEndQualifierDto.wholeSp:
            break;
        }

        if (segmentData.isComplete) {
          final startSegment = segmentProfiles.firstMatch(segmentProfilesReferences[segmentData.startIndex!]);
          final endSegment = segmentProfiles.firstMatch(segmentProfilesReferences[segmentData.endIndex!]);
          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);
          final speed =
              asrTemporaryConstrain.additionalSpeedRestriction?.asrSpeed ??
              asrTemporaryConstrain.parallelAsrConstraintDto?.speedNsp.speed;

          result.add(
            AdditionalSpeedRestriction(
              kmFrom: startKilometreMap[segmentData.startLocation]!.first,
              kmTo: endKilometreMap[segmentData.endLocation]!.first,
              orderFrom: segmentData.startOrder!,
              orderTo: segmentData.endOrder!,
              restrictionFrom: asrTemporaryConstrain.startTime,
              restrictionUntil: asrTemporaryConstrain.endTime,
              speed: speed,
              reason: asrTemporaryConstrain.temporaryConstraintReasons.toLocalizedString,
            ),
          );

          segmentsData.remove(parallelAsrId);
        }
      }
    }

    for (final segmentData in segmentsData.values) {
      if (segmentData.isIncomplete) {
        _log.warning('Incomplete additional speed restriction found: $segmentData');
      }
    }

    return result;
  }

  static bool _shouldSkipAsrDueToJourneyTimes(
    List<ServicePoint> servicePoints,
    TemporaryConstraintsDto asrTemporaryConstrain,
  ) {
    const timeBuffer = Duration(minutes: 30);

    final journeyStartTime = servicePoints.firstOrNull?.arrivalDepartureTime?.operationalDepartureTime;
    final journeyEndTime = servicePoints.lastOrNull?.arrivalDepartureTime?.operationalArrivalTime;

    final journeyStartMinusBuffer = journeyStartTime?.subtract(timeBuffer);
    final journeyEndPlusBuffer = journeyEndTime?.add(timeBuffer);

    // Skip ASR if it ends before the journey start time minus timeBuffer
    if (asrTemporaryConstrain.endTime != null &&
        journeyStartMinusBuffer != null &&
        asrTemporaryConstrain.endTime!.isBefore(journeyStartMinusBuffer)) {
      return true;
    }

    // Skip ASR if it starts after the journey end time plus timeBuffer
    if (asrTemporaryConstrain.startTime != null &&
        journeyEndPlusBuffer != null &&
        asrTemporaryConstrain.startTime!.isAfter(journeyEndPlusBuffer)) {
      return true;
    }

    return false;
  }

  static Iterable<CABSignaling> _cabSignalingStart(Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    return trackEquipmentSegments.withCABSignalingStart.map(
      (element) => CABSignaling(isStart: true, order: element.startOrder!, kilometre: element.startKm),
    );
  }

  /// Returns CAB signaling end for ETCS level 2 segments.
  ///
  /// NewLineSpeed is delivered by TMS VAD at the end location of an ETCS level 2 segment.
  /// NewLineSpeed needs to be added to [journeyData] first to get speedData for CAB signaling end.
  ///
  /// Used NewLineSpeed for CAB signaling end will be removed from [journeyData]
  static Iterable<CABSignaling> _cabSignalingEnd(
    Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments,
    List<BaseData> journeyData,
  ) {
    final cabEndSpeedChanges = <BaseData>[];
    final cabSignalingEnds = <CABSignaling>[];
    for (final segment in trackEquipmentSegments.withCABSignalingEnd) {
      final speedChange = journeyData.firstWhereOrNull(
        (data) => data.type == Datatype.speedChange && data.order == segment.endOrder,
      );
      if (speedChange != null) {
        cabEndSpeedChanges.add(speedChange);
      }
      cabSignalingEnds.add(
        CABSignaling(
          isStart: false,
          order: segment.endOrder!,
          kilometre: segment.endKm,
          speeds: speedChange?.speeds,
        ),
      );
    }

    // remove SpeedChange that were used for CAB signaling end
    for (final speedChange in cabEndSpeedChanges) {
      journeyData.remove(speedChange);
    }

    return cabSignalingEnds;
  }

  static List<CommunicationNetworkChange> _parseCommunicationNetworkChanges(
    List<SegmentProfileReferenceDto> segmentProfileReferences,
    List<SegmentProfileDto> segmentProfiles,
  ) {
    return segmentProfileReferences
        .mapIndexed((index, reference) {
          final segmentProfile = segmentProfiles.firstMatch(reference);
          final communicationNetworks = segmentProfile.contextInformation?.communicationNetworks;
          return communicationNetworks?.map((element) {
            if (element.startLocation != element.endLocation) {
              _log.warning(
                'CommunicationNetwork found without identical location (start=${element.startLocation} end=${element.endLocation}).',
              );
            }

            return CommunicationNetworkChange(
              type: element.communicationNetworkType.communicationNetworkType,
              order: calculateOrder(index, element.startLocation),
            );
          });
        })
        .nonNulls
        .flattened
        .toList();
  }

  static Iterable<RadioContactList> _parseContactLists(
    List<SegmentProfileReferenceDto> segmentProfileReferences,
    List<SegmentProfileDto> segmentProfiles,
  ) {
    return segmentProfileReferences
        .mapIndexed((index, reference) {
          final segmentProfile = segmentProfiles.firstMatch(reference);

          final contactLists = segmentProfile.contextInformation?.contactLists;
          return contactLists?.map((contactList) {
            final identifiableContacts = contactList.contacts.where(
              (c) => c.otherContactType != null && c.otherContactType!.contactIdentifier != null,
            );
            return RadioContactList(
              order: calculateOrder(index, contactList.startLocation ?? 0),
              endOrder: calculateOrder(index, contactList.endLocation ?? 0),
              contacts: identifiableContacts.map(
                (e) => switch (e.mainContact) {
                  true => MainContact(
                    contactIdentifier: e.otherContactType!.contactIdentifier!,
                    contactRole: e.contactRole,
                  ),
                  false => SelectiveContact(
                    contactIdentifier: e.otherContactType!.contactIdentifier!,
                    contactRole: e.contactRole,
                  ),
                },
              ),
            );
          });
        })
        .nonNulls
        .flattened
        .toList();
  }

  static Set<BreakSeries> _parseAvailableBreakSeries(List<BaseData> journeyData) {
    return journeyData
        .expand((it) => it.allStaticSpeeds)
        .where((it) => it.breakSeries != null)
        .map((it) => BreakSeries(trainSeries: it.trainSeries, breakSeries: it.breakSeries!))
        .toSet();
  }

  static TrainCharacteristicsDto? _resolveFirstTrainCharacteristics(
    JourneyProfileDto journey,
    List<TrainCharacteristicsDto> trainCharacteristics,
  ) {
    final firstTrainRef = journey.trainCharacteristicsRefSet.firstOrNull;
    if (firstTrainRef == null) return null;

    return trainCharacteristics.firstWhereGivenOrNull(firstTrainRef);
  }

  static List<UncodedOperationalIndication> _parseUncodedOperationalIndication(
    int segmentIndex,
    SegmentProfileReferenceDto segmentProfileReference,
  ) {
    final indications = segmentProfileReference.jpContextInformation?.operationalIndications;
    if (indications == null) return [];

    mapToModel(OperationalIndicationNspDto uncoded) {
      final startLocation = uncoded.constraint?.startLocation;
      if (startLocation == null) {
        _log.warning('Uncoded operational indication without location found: $uncoded');
        return null;
      }
      return UncodedOperationalIndication(
        order: calculateOrder(segmentIndex, startLocation),
        texts: [uncoded.uncodedText],
      );
    }

    return indications
        .where((indication) => indication.operationalIndicationType == OperationalIndicationTypeDto.uncoded)
        .map(mapToModel)
        .nonNulls
        .mergeOnSameLocation()
        .toList();
  }

  static List<TramArea> _parseTramAreas(List<SegmentProfileDto> segmentProfiles) {
    final List<TramArea> result = [];

    final segmentData = _SegmentMapperData();
    int? amountTramSignals;

    for (int segmentIndex = 0; segmentIndex < segmentProfiles.length; segmentIndex++) {
      final segmentProfile = segmentProfiles[segmentIndex];

      if (segmentProfile.areas == null) continue;

      for (final tramArea in segmentProfile.areas!.tramAreas) {
        switch (tramArea.startEndQualifier) {
          case StartEndQualifierDto.starts:
            segmentData.startLocation = tramArea.startLocation;
            segmentData.startIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            break;
          case StartEndQualifierDto.startsEnds:
            segmentData.startLocation = tramArea.startLocation;
            segmentData.startIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            continue next;
          next:
          case StartEndQualifierDto.ends:
            segmentData.endLocation = tramArea.endLocation;
            segmentData.endIndex = segmentIndex;
            break;
          case StartEndQualifierDto.wholeSp:
            break;
        }

        if (segmentData.isComplete && amountTramSignals != null) {
          final startSegment = segmentProfiles[segmentData.startIndex!];
          final endSegment = segmentProfiles[segmentData.endIndex!];

          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);

          result.add(
            TramArea(
              order: segmentData.startOrder!,
              kilometre: startKilometreMap[segmentData.startLocation]!,
              endKilometre: endKilometreMap[segmentData.endLocation]!.first,
              amountTramSignals: amountTramSignals,
            ),
          );

          segmentData.reset();
          amountTramSignals = null;
        }
      }
    }

    if (segmentData.isIncomplete) {
      _log.warning('Incomplete tram area found: $segmentData');
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
        _log.warning(
          'There should at least be two bracket stations for a segment. Found service points: $bracketStations',
        );
      }

      final orders = bracketStations.map((it) => it.order);
      return BracketStationSegment(
        mainStationAbbreviation: bracketStations.first.bracketMainStation!.abbreviation,
        startOrder: orders.min,
        endOrder: orders.max,
      );
    }).toList();
  }

  static Map<String, List<String>> _generateLineFootNoteLocationMap(Iterable<LineFootNote> footNotes) {
    final lineFootNoteLocations = <String, List<String>>{};
    for (final lineNote in footNotes) {
      if (lineNote.footNote.identifier == null) continue;

      if (lineFootNoteLocations.containsKey(lineNote.footNote.identifier)) {
        lineFootNoteLocations[lineNote.footNote.identifier]!.add(lineNote.locationName);
      } else {
        lineFootNoteLocations[lineNote.footNote.identifier!] = [lineNote.locationName];
      }
    }
    return lineFootNoteLocations;
  }

  static Delay? _parseDelay(RelatedTrainInformationDto? relatedTrainInformation) {
    final duration = relatedTrainInformation?.ownTrain.trainLocationInformation.delay?.delayAsDuration;
    final positionSpeed = relatedTrainInformation?.ownTrain.trainLocationInformation.positionSpeed;
    final location = '${positionSpeed?.spId}${positionSpeed?.location}';
    return duration != null ? Delay(value: duration, location: location) : null;
  }

  static SplayTreeMap<int, Iterable<TrainSeriesSpeed>> _gatherLineSpeeds(List<BaseData> journeyData) {
    final SplayTreeMap<int, Iterable<TrainSeriesSpeed>> result = SplayTreeMap();

    for (final data in journeyData) {
      if (data.speeds != null) {
        result[data.order] = data.speeds!;
      }
    }

    return result;
  }

  static SplayTreeMap<int, SingleSpeed> _gatherCalculatedSpeeds(List<BaseData> journeyData) {
    final SplayTreeMap<int, SingleSpeed> result = SplayTreeMap();

    for (final data in journeyData.whereType<ServicePoint>()) {
      if (data.calculatedSpeed != null) {
        result[data.order] = data.calculatedSpeed!;
      }
    }

    return result;
  }
}

class _SegmentMapperData {
  int? startIndex;
  int? endIndex;
  double? startLocation;
  double? endLocation;

  int? get startOrder => _calculateOrder(startIndex, startLocation);

  int? get endOrder => _calculateOrder(endIndex, endLocation);

  int? _calculateOrder(int? segmentIndex, double? location) {
    if (segmentIndex == null || location == null) return null;
    return calculateOrder(segmentIndex, location);
  }

  bool get isComplete => startIndex != null && endIndex != null && startLocation != null && endLocation != null;

  bool get isIncomplete => startIndex != null || endIndex != null || startLocation != null || endLocation != null;

  void reset() {
    startIndex = null;
    endIndex = null;
    startLocation = null;
    endLocation = null;
  }

  @override
  String toString() {
    return '_SegmentMapperData{startSegmentIndex: $startIndex, endSegmentIndex: $endIndex, startLocation: $startLocation, endLocation: $endLocation}';
  }
}
