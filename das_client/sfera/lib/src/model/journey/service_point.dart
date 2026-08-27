import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';

class const ServicePoint({
  required final String name,
  required final String abbreviation,
  required final String locationCode,
  required super.order,
  required super.kilometre,
  super.localSpeeds,
  final bool mandatoryStop = false,
  final bool isStop = false,
  final bool isStation = false,
  final bool betweenBrackets = false,
  final bool isAdditional = false,
  final BracketMainStation? bracketMainStation,
  final List<TrainSeriesSpeed>? graduatedSpeedInfo,
  final DecisiveGradient? decisiveGradient,
  final ArrivalDepartureTime? arrivalDepartureTime,
  final StationSign? stationSign1,
  final StationSign? stationSign2,
  final String? trackGroup,
  final List<StationProperty> properties = const [],
  final List<LocalRegulationSection> localRegulationSections = const [],
  final DepartureAuthorization? departureAuthorization,
  super.lastModificationDate,
  super.lastModificationType,
}) extends JourneyPoint {
  this : super(dataType: .servicePoint);

  List<TrainSeriesSpeed> relevantGraduatedSpeedInfo(BrakeSeries? brakeSeries) {
    final speedInfo = graduatedSpeedInfo ?? [];
    return speedInfo.where((speed) => speed.trainSeries == brakeSeries?.trainSeries && speed.text != null).toList();
  }

  Iterable<StationProperty> propertiesFor(BrakeSeries? brakeSeries) {
    return properties.where(
      (property) =>
          property.speeds == null ||
          property.speeds?.speedFor(
                brakeSeries?.trainSeries,
                brakedWeightPercentage: brakeSeries?.brakedWeightPercentage,
              ) !=
              null,
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
  OrderPriority get orderPriority => .servicePoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicePoint &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          name == other.name &&
          abbreviation == other.abbreviation &&
          mandatoryStop == other.mandatoryStop &&
          isStop == other.isStop &&
          isStation == other.isStation &&
          isAdditional == other.isAdditional &&
          betweenBrackets == other.betweenBrackets &&
          bracketMainStation == other.bracketMainStation &&
          DeepCollectionEquality().equals(graduatedSpeedInfo, other.graduatedSpeedInfo) &&
          decisiveGradient == other.decisiveGradient &&
          arrivalDepartureTime == other.arrivalDepartureTime &&
          stationSign1 == other.stationSign1 &&
          stationSign2 == other.stationSign2 &&
          trackGroup == other.trackGroup &&
          departureAuthorization == other.departureAuthorization &&
          ListEquality().equals(properties, other.properties) &&
          DeepCollectionEquality().equals(localSpeeds, other.localSpeeds);

  @override
  int get hashCode =>
      dataType.hashCode ^
      order.hashCode ^
      Object.hashAll(kilometre) ^
      name.hashCode ^
      abbreviation.hashCode ^
      mandatoryStop.hashCode ^
      isStop.hashCode ^
      isStation.hashCode ^
      isAdditional.hashCode ^
      betweenBrackets.hashCode ^
      bracketMainStation.hashCode ^
      Object.hashAll(graduatedSpeedInfo ?? []) ^
      decisiveGradient.hashCode ^
      arrivalDepartureTime.hashCode ^
      stationSign1.hashCode ^
      stationSign2.hashCode ^
      trackGroup.hashCode ^
      departureAuthorization.hashCode ^
      Object.hashAll(properties) ^
      Object.hashAll(localSpeeds ?? []);

  @override
  String toString() {
    return 'ServicePoint{'
        'order: $order, '
        'kilometre: $kilometre, '
        'name: $name, '
        'abbreviation: $abbreviation, '
        'mandatoryStop: $mandatoryStop, '
        'isStop: $isStop, '
        'isStation: $isStation, '
        'isAdditional: $isAdditional, '
        'betweenBrackets: $betweenBrackets, '
        'bracketMainStation: $bracketMainStation, '
        'graduatedSpeedInfo: $graduatedSpeedInfo, '
        'decisiveGradient: $decisiveGradient, '
        'localSpeeds: $localSpeeds, '
        'arrivalDepartureTime: $arrivalDepartureTime, '
        'stationSign1: $stationSign1, '
        'stationSign2: $stationSign2, '
        'trackGroup: $trackGroup, '
        'departureAuthorization: $departureAuthorization, '
        'properties: $properties, '
        'localRegulationSections: $localRegulationSections'
        '}';
  }
}
