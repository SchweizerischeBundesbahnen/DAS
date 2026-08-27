import 'dart:collection';

import 'package:core_data/component.dart';
import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
class Metadata({
  final TrainIdentification? trainIdentification,
  final Delay? delay,
  final BrakeSeries? brakeSeries,
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions = const [],
  final List<NonStandardTrackEquipmentSegment> nonStandardTrackEquipmentSegments = const [],
  final List<BracketStationSegment> bracketStationSegments = const [],
  final Iterable<AdvisedSpeedSegment> advisedSpeedSegments = const [],
  final Iterable<ShortTermChange> shortTermChanges = const [],
  final Set<BrakeSeries> availableBrakeSeries = const {},
  final List<CommunicationNetworkChange> communicationNetworkChanges = const [],
  final Map<String, List<String>> lineFootNoteLocations = const {},
  final Iterable<RadioContactList> radioContactLists = const [],
  final List<LevelCrossingGroup> levelCrossingGroups = const [],
  final List<SuspiciousSegment> suspiciousSegments = const [],
  this.signaledPosition,
  DateTime? timestamp,
  bool? anyOperationalArrivalDepartureTimes,
  SplayTreeMap<int, Iterable<TrainSeriesSpeed>>? lineSpeeds,
  SplayTreeMap<int, SingleSpeed?>? calculatedSpeeds,
}) {
  this
    : timestamp = timestamp ?? DateTime.now(),
      anyOperationalArrivalDepartureTimes = anyOperationalArrivalDepartureTimes ?? false,
      lineSpeeds = lineSpeeds ?? SplayTreeMap<int, Iterable<TrainSeriesSpeed>>(),
      calculatedSpeeds = calculatedSpeeds ?? SplayTreeMap<int, SingleSpeed>();

  /// The position received by TMS VAD within a related train information event.
  final SignaledPosition? signaledPosition;

  final DateTime timestamp;
  final bool anyOperationalArrivalDepartureTimes;
  final SplayTreeMap<int, Iterable<TrainSeriesSpeed>> lineSpeeds;
  final SplayTreeMap<int, SingleSpeed?> calculatedSpeeds;
}
