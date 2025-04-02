import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station_segment.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:das_client/model/journey/contact_list.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class Metadata {
  Metadata({
    DateTime? timestamp,
    this.nextStop,
    this.lastPosition,
    this.currentPosition,
    this.routeStart,
    this.routeEnd,
    this.delay,
    this.breakSeries,
    this.additionalSpeedRestrictions = const [],
    this.nonStandardTrackEquipmentSegments = const [],
    this.bracketStationSegments = const [],
    this.availableBreakSeries = const {},
    this.communicationNetworkChanges = const [],
    this.lineFootNoteLocations = const {},
    this.contactLists = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final ServicePoint? nextStop;
  final BaseData? lastPosition;
  final BaseData? currentPosition;
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions;
  final BaseData? routeStart;
  final BaseData? routeEnd;
  final Duration? delay;
  final List<NonStandardTrackEquipmentSegment> nonStandardTrackEquipmentSegments;
  final List<CommunicationNetworkChange> communicationNetworkChanges;
  final List<BracketStationSegment> bracketStationSegments;
  final BreakSeries? breakSeries;
  final Set<BreakSeries> availableBreakSeries;
  final Map<String, List<LocalizedString>> lineFootNoteLocations;
  final List<ContactList> contactLists;
}
