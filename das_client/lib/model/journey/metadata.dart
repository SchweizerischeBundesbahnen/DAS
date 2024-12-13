import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/model/journey/train_series.dart';

class Metadata {
  Metadata({
    this.nextStop,
    this.currentPosition,
    this.routeStart,
    this.routeEnd,
    this.breakSeries,
    this.additionalSpeedRestrictions = const [],
    this.nonStandardTrackEquipmentSegments = const [],
    this.availableBreakSeries = const {},
  });

  final ServicePoint? nextStop;
  final BaseData? currentPosition;
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions;
  final BaseData? routeStart;
  final BaseData? routeEnd;
  final List<NonStandardTrackEquipmentSegment> nonStandardTrackEquipmentSegments;
  final BreakSeries? breakSeries;
  final Set<BreakSeries> availableBreakSeries;
}
