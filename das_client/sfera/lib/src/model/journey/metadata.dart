import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class Metadata {
  Metadata({
    this.trainIdentification,
    this.signaledPosition,
    this.journeyStart,
    this.journeyEnd,
    this.delay,
    this.brakeSeries,
    this.additionalSpeedRestrictions = const [],
    this.nonStandardTrackEquipmentSegments = const [],
    this.bracketStationSegments = const [],
    this.advisedSpeedSegments = const [],
    this.shortTermChanges = const [],
    this.availableBrakeSeries = const {},
    this.communicationNetworkChanges = const [],
    this.lineFootNoteLocations = const {},
    this.radioContactLists = const [],
    this.levelCrossingGroups = const [],
    this.suspiciousSegments = const [],
    DateTime? timestamp,
    bool? anyOperationalArrivalDepartureTimes,
    SplayTreeMap<int, Iterable<TrainSeriesSpeed>>? lineSpeeds,
    SplayTreeMap<int, SingleSpeed?>? calculatedSpeeds,
  }) : timestamp = timestamp ?? DateTime.now(),
       anyOperationalArrivalDepartureTimes = anyOperationalArrivalDepartureTimes ?? false,
       lineSpeeds = lineSpeeds ?? SplayTreeMap<int, Iterable<TrainSeriesSpeed>>(),
       calculatedSpeeds = calculatedSpeeds ?? SplayTreeMap<int, SingleSpeed>();

  final TrainIdentification? trainIdentification;
  final DateTime timestamp;

  /// The position received by TMS VAD within a related train information event.
  final SignaledPosition? signaledPosition;
  final JourneyPoint? journeyStart;
  final JourneyPoint? journeyEnd;
  final Delay? delay;
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions;
  final bool anyOperationalArrivalDepartureTimes;
  final List<NonStandardTrackEquipmentSegment> nonStandardTrackEquipmentSegments;
  final List<CommunicationNetworkChange> communicationNetworkChanges;
  final List<BracketStationSegment> bracketStationSegments;
  final Iterable<AdvisedSpeedSegment> advisedSpeedSegments;
  final Iterable<ShortTermChange> shortTermChanges;
  final BrakeSeries? brakeSeries;
  final Set<BrakeSeries> availableBrakeSeries;
  final Map<String, List<String>> lineFootNoteLocations;
  final Iterable<RadioContactList> radioContactLists;
  final SplayTreeMap<int, Iterable<TrainSeriesSpeed>> lineSpeeds;
  final SplayTreeMap<int, SingleSpeed?> calculatedSpeeds;
  final List<LevelCrossingGroup> levelCrossingGroups;
  final List<SuspiciousSegment> suspiciousSegments;

  Metadata copyWith({
    TrainIdentification? trainIdentification,
    SignaledPosition? signaledPosition,
    JourneyPoint? journeyStart,
    JourneyPoint? journeyEnd,
    Delay? delay,
    BrakeSeries? brakeSeries,
    List<AdditionalSpeedRestriction>? additionalSpeedRestrictions,
    List<NonStandardTrackEquipmentSegment>? nonStandardTrackEquipmentSegments,
    List<BracketStationSegment>? bracketStationSegments,
    Iterable<AdvisedSpeedSegment>? advisedSpeedSegments,
    Iterable<ShortTermChange>? shortTermChanges,
    Set<BrakeSeries>? availableBrakeSeries,
    List<CommunicationNetworkChange>? communicationNetworkChanges,
    Map<String, List<String>>? lineFootNoteLocations,
    Iterable<RadioContactList>? radioContactLists,
    List<LevelCrossingGroup>? levelCrossingGroups,
    List<SuspiciousSegment>? suspiciousSegments,
  }) {
    return Metadata(
      trainIdentification: trainIdentification ?? this.trainIdentification,
      signaledPosition: signaledPosition ?? this.signaledPosition,
      journeyStart: journeyStart ?? this.journeyStart,
      journeyEnd: journeyEnd ?? this.journeyEnd,
      delay: delay ?? this.delay,
      brakeSeries: brakeSeries ?? this.brakeSeries,
      additionalSpeedRestrictions: additionalSpeedRestrictions ?? this.additionalSpeedRestrictions,
      nonStandardTrackEquipmentSegments: nonStandardTrackEquipmentSegments ?? this.nonStandardTrackEquipmentSegments,
      bracketStationSegments: bracketStationSegments ?? this.bracketStationSegments,
      advisedSpeedSegments: advisedSpeedSegments ?? this.advisedSpeedSegments,
      shortTermChanges: shortTermChanges ?? this.shortTermChanges,
      availableBrakeSeries: availableBrakeSeries ?? this.availableBrakeSeries,
      communicationNetworkChanges: communicationNetworkChanges ?? this.communicationNetworkChanges,
      lineFootNoteLocations: lineFootNoteLocations ?? this.lineFootNoteLocations,
      radioContactLists: radioContactLists ?? this.radioContactLists,
      levelCrossingGroups: levelCrossingGroups ?? this.levelCrossingGroups,
      suspiciousSegments: suspiciousSegments ?? this.suspiciousSegments,
    );
  }
}
