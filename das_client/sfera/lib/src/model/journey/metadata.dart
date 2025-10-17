import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class Metadata {
  Metadata({
    DateTime? timestamp,
    this.signaledPosition,
    this.journeyStart,
    this.journeyEnd,
    this.delay,
    this.breakSeries,
    bool? anyOperationalArrivalDepartureTimes,
    this.additionalSpeedRestrictions = const [],
    this.nonStandardTrackEquipmentSegments = const [],
    this.bracketStationSegments = const [],
    this.advisedSpeedSegments = const [],
    this.availableBreakSeries = const {},
    this.communicationNetworkChanges = const [],
    this.lineFootNoteLocations = const {},
    this.radioContactLists = const [],
    this.levelCrossingGroups = const [],
    SplayTreeMap<int, Iterable<TrainSeriesSpeed>>? lineSpeeds,
    SplayTreeMap<int, SingleSpeed?>? calculatedSpeeds,
  }) : timestamp = timestamp ?? DateTime.now(),
       anyOperationalArrivalDepartureTimes = anyOperationalArrivalDepartureTimes ?? false,
       lineSpeeds = lineSpeeds ?? SplayTreeMap<int, Iterable<TrainSeriesSpeed>>(),
       calculatedSpeeds = calculatedSpeeds ?? SplayTreeMap<int, SingleSpeed>();

  final DateTime timestamp;
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
  final BreakSeries? breakSeries;
  final Set<BreakSeries> availableBreakSeries;
  final Map<String, List<String>> lineFootNoteLocations;
  final Iterable<RadioContactList> radioContactLists;
  final SplayTreeMap<int, Iterable<TrainSeriesSpeed>> lineSpeeds;
  final SplayTreeMap<int, SingleSpeed?> calculatedSpeeds;
  final List<LevelCrossingGroup> levelCrossingGroups;
}
