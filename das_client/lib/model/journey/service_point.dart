import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/graduated_speed_data.dart';
import 'package:das_client/model/localized_string.dart';

class ServicePoint extends BaseData {
  ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.speedData,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.bracketStation,
    this.stationSpeedData,
    this.graduatedSpeedData,
  }) : super(type: Datatype.servicePoint);

  final LocalizedString name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketStation? bracketStation;
  final GraduatedSpeedData? stationSpeedData;
  final GraduatedSpeedData? graduatedSpeedData;

  @override
  String toString() {
    return 'ServicePoint(order: $order, kilometre: $kilometre, name: $name, mandatoryStop: $mandatoryStop, isStop: $isStop, isStation: $isStation, bracketStation: $bracketStation, speedData: $speedData, stationSpeedData: $stationSpeedData)';
  }
}
