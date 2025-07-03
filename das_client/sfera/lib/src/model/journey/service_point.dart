import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';
import 'package:sfera/src/model/journey/station_property.dart';
import 'package:sfera/src/model/journey/station_sign.dart';
import 'package:sfera/src/model/journey/train_series_speed.dart';

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
    this.stationSign1,
    this.stationSign2,
    this.properties = const [],
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
  final StationSign? stationSign1;
  final StationSign? stationSign2;
  final List<StationProperty> properties;

  List<TrainSeriesSpeed> relevantGraduatedSpeedInfo(BreakSeries? breakSeries) {
    final speedInfo = graduatedSpeedInfo ?? [];
    return speedInfo.where((speed) => speed.trainSeries == breakSeries?.trainSeries && speed.text != null).toList();
  }

  Iterable<StationProperty> propertiesFor(BreakSeries? breakSeries) {
    return properties.where(
      (property) =>
          property.speeds == null ||
          property.speeds?.speedFor(breakSeries?.trainSeries, breakSeries: breakSeries?.breakSeries) != null,
    );
  }

  @override
  Iterable<TrainSeriesSpeed> get allSpeeds {
    return [
      ...super.allSpeeds,
      ...?graduatedSpeedInfo,
      ...properties.map((it) => it.speeds).nonNulls.expand((it) => it),
    ];
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
        ', stationSign1: $stationSign1'
        ', stationSign2: $stationSign2'
        ', properties: $properties'
        ')';
  }
}
