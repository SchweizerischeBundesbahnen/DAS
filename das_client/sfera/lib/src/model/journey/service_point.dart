import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';

class ServicePoint extends BaseData {
  const ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.speeds,
    super.localSpeeds,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.bracketMainStation,
    this.calculatedSpeed,
    this.graduatedSpeedInfo,
    this.decisiveGradient,
    this.arrivalDepartureTime,
  }) : super(type: Datatype.servicePoint);

  final String name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketMainStation? bracketMainStation;
  final List<TrainSeriesSpeed>? graduatedSpeedInfo;
  final SingleSpeed? calculatedSpeed;
  final DecisiveGradient? decisiveGradient;
  final ArrivalDepartureTime? arrivalDepartureTime;

  List<TrainSeriesSpeed> relevantGraduatedSpeedInfo(BreakSeries? breakSeries) {
    final speedInfo = graduatedSpeedInfo ?? [];
    return speedInfo.where((speed) => speed.trainSeries == breakSeries?.trainSeries && speed.text != null).toList();
  }

  @override
  String toString() {
    return 'ServicePoint('
        'order: $order'
        ', kilometre: $kilometre'
        ', name: $name'
        ', mandatoryStop: $mandatoryStop'
        ', isStop: $isStop'
        ', isStation: $isStation'
        ', bracketMainStation: $bracketMainStation'
        ', speeds: $speeds'
        ', localSpeeds: $localSpeeds'
        ', calculatedSpeed: $calculatedSpeed'
        ', arrivalDepartureTime: $arrivalDepartureTime'
        ')';
  }
}
