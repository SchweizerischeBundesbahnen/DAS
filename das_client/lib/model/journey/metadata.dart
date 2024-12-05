import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/train_series.dart';

class Metadata {
  Metadata(
      {this.nextStop,
      this.currentPosition,
      this.routeStart,
      this.routeEnd,
      List<AdditionalSpeedRestriction>? additionalSpeedRestrictions,
      this.trainSeries = TrainSeries.R,
      this.breakSeries = 150})
      : additionalSpeedRestrictions = additionalSpeedRestrictions ?? [];

  final ServicePoint? nextStop;
  final BaseData? currentPosition;
  final List<AdditionalSpeedRestriction> additionalSpeedRestrictions;
  final BaseData? routeStart;
  final BaseData? routeEnd;
  final TrainSeries trainSeries;
  final int breakSeries;
}
