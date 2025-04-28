import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/journey/speeds.dart';

class ServicePoint extends BaseData {
  const ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.speedData,
    super.localSpeedData,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.bracketMainStation,
    this.graduatedSpeedInfo,
  }) : super(type: Datatype.servicePoint);

  final String name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketMainStation? bracketMainStation;
  final SpeedData? graduatedSpeedInfo;

  List<Speeds> relevantGraduatedSpeedInfo(BreakSeries? breakSeries) {
    final speedInfo = graduatedSpeedInfo?.speeds ?? [];
    return speedInfo.where((speed) => speed.trainSeries == breakSeries?.trainSeries && speed.text != null).toList();
  }

  @override
  String toString() {
    return 'ServicePoint(order: $order, kilometre: $kilometre, name: $name, mandatoryStop: $mandatoryStop, isStop: $isStop, isStation: $isStation, bracketMainStation: $bracketMainStation, speedData: $speedData, localSpeedData: $localSpeedData)';
  }
}
