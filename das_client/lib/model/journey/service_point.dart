import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/localized_string.dart';

class ServicePoint extends BaseData {
  ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.speedData,
    super.localSpeedData,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.bracketStation,
    this.graduatedSpeedInfo,
  }) : super(type: Datatype.servicePoint);

  final LocalizedString name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketStation? bracketStation;
  final SpeedData? graduatedSpeedInfo;

  @override
  String toString() {
    return 'ServicePoint(order: $order, kilometre: $kilometre, name: $name, mandatoryStop: $mandatoryStop, isStop: $isStop, isStation: $isStation, bracketStation: $bracketStation, speedData: $speedData, localSpeedData: $localSpeedData)';
  }
}
