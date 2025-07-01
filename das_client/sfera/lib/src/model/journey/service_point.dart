import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';

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
  final SpeedData? graduatedSpeedInfo;
  final DecisiveGradient? decisiveGradient;
  final ArrivalDepartureTime? arrivalDepartureTime;
  final StationSign? stationSign1;
  final StationSign? stationSign2;
  final List<StationProperty> properties;

  List<Speeds> relevantGraduatedSpeedInfo(BreakSeries? breakSeries) {
    final speedInfo = graduatedSpeedInfo?.speeds ?? [];
    return speedInfo.where((speed) => speed.trainSeries == breakSeries?.trainSeries && speed.text != null).toList();
  }

  Iterable<StationProperty> relevantProperties(BreakSeries? breakSeries) {
    return properties.where(
      (property) =>
          property.speedData == null ||
          property.speedData?.speedsFor(breakSeries?.trainSeries, breakSeries?.breakSeries) != null,
    );
  }

  @override
  Iterable<Speeds> get allSpeedData {
    return [
      ...super.allSpeedData,
      ...?graduatedSpeedInfo?.speeds,
      ...properties.map((it) => it.speedData).nonNulls.expand((it) => it.speeds),
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
        ', speedData: $speedData'
        ', localSpeedData: $localSpeedData'
        ', arrivalDepartureTime: $arrivalDepartureTime'
        ', stationSign1: $stationSign1'
        ', stationSign2: $stationSign2'
        ', properties: $properties'
        ')';
  }
}
