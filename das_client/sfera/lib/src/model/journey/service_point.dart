import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';

class ServicePoint extends JourneyPoint {
  const ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.localSpeeds,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.betweenBrackets = false,
    this.bracketMainStation,
    this.graduatedSpeedInfo,
    this.decisiveGradient,
    this.arrivalDepartureTime,
    this.stationSign1,
    this.stationSign2,
    this.properties = const [],
    this.localRegulationSections = const [],
  }) : super(type: Datatype.servicePoint);

  final String name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final bool betweenBrackets;
  final BracketMainStation? bracketMainStation;
  final List<TrainSeriesSpeed>? graduatedSpeedInfo;
  final DecisiveGradient? decisiveGradient;
  final ArrivalDepartureTime? arrivalDepartureTime;
  final StationSign? stationSign1;
  final StationSign? stationSign2;
  final List<StationProperty> properties;
  final List<LocalRegulationSection> localRegulationSections;

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
  Iterable<TrainSeriesSpeed> get allStaticSpeeds {
    return [
      ...super.allStaticSpeeds,
      ...?graduatedSpeedInfo,
      ...properties.map((it) => it.speeds).nonNulls.expand((it) => it),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicePoint &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          name == other.name &&
          mandatoryStop == other.mandatoryStop &&
          isStop == other.isStop &&
          isStation == other.isStation &&
          bracketMainStation == other.bracketMainStation &&
          DeepCollectionEquality().equals(graduatedSpeedInfo, other.graduatedSpeedInfo) &&
          decisiveGradient == other.decisiveGradient &&
          arrivalDepartureTime == other.arrivalDepartureTime &&
          stationSign1 == other.stationSign1 &&
          stationSign2 == other.stationSign2 &&
          ListEquality().equals(properties, other.properties) &&
          DeepCollectionEquality().equals(localSpeeds, other.localSpeeds);

  @override
  int get hashCode =>
      order.hashCode ^
      Object.hashAll(kilometre) ^
      name.hashCode ^
      mandatoryStop.hashCode ^
      isStop.hashCode ^
      isStation.hashCode ^
      bracketMainStation.hashCode ^
      Object.hashAll(graduatedSpeedInfo ?? []) ^
      decisiveGradient.hashCode ^
      arrivalDepartureTime.hashCode ^
      stationSign1.hashCode ^
      stationSign2.hashCode ^
      Object.hashAll(properties) ^
      Object.hashAll(localSpeeds ?? []);

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
        ', localSpeeds: $localSpeeds'
        ', arrivalDepartureTime: $arrivalDepartureTime'
        ', stationSign1: $stationSign1'
        ', stationSign2: $stationSign2'
        ', properties: $properties'
        ')';
  }
}
