import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/service_point.dart';

class Metadata {
  Metadata(
      {this.nextStop,
      this.currentPosition,
      this.routeStart,
      this.routeEnd,
      List<AdditionalSpeedRestriction>? additionalSpeedRestrictions})
      : additionalSpeedRestrictions = additionalSpeedRestrictions ?? [];

  final ServicePoint? nextStop;
  final BaseData? currentPosition;
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions;
  final BaseData? routeStart;
  final BaseData? routeEnd;
}
