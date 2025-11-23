import 'package:json_annotation/json_annotation.dart';

part 'formation_run.g.dart';

@JsonSerializable()
class FormationRun {
  FormationRun({
    required this.inspectionDateTime,
    required this.tafTapLocationReferenceStart,
    required this.tafTapLocationReferenceEnd,
    required this.tractionLengthInCm,
    required this.hauledLoadLengthInCm,
    required this.formationLengthInCm,
    required this.tractionWeightInT,
    required this.hauledLoadWeightInT,
    required this.formationWeightInT,
    required this.tractionBrakedWeightInT,
    required this.hauledLoadBrakedWeightInT,
    required this.formationBrakedWeightInT,
    required this.tractionHoldingForceInHectoNewton,
    required this.hauledLoadHoldingForceInHectoNewton,
    required this.formationHoldingForceInHectoNewton,
    required this.simTrain,
    required this.carCarrierVehicle,
    required this.dangerousGoods,
    required this.vehiclesCount,
    required this.vehiclesWithBrakeDesignLlAndKCount,
    required this.vehiclesWithBrakeDesignDCount,
    required this.vehiclesWithDisabledBrakesCount,
    required this.axleLoadMaxInKg,
    required this.gradientUphillMaxInPermille,
    required this.gradientDownhillMaxInPermille,
    this.trainCategoryCode,
    this.brakedWeightPercentage,
    this.tractionMaxSpeedInKmh,
    this.hauledLoadMaxSpeedInKmh,
    this.formationMaxSpeedInKmh,
    this.brakePositionGForLeadingTraction,
    this.brakePositionGForBrakeUnit1to5,
    this.brakePositionGForLoadHauled,
    this.additionalTractions = const [],
    this.europeanVehicleNumberFirst,
    this.europeanVehicleNumberLast,
    this.routeClass,
    this.slopeMaxForHoldingForceMinInPermille,
  });

  factory FormationRun.fromJson(Map<String, dynamic> json) {
    return _$FormationRunFromJson(json);
  }

  final DateTime inspectionDateTime;
  final String tafTapLocationReferenceStart;
  final String tafTapLocationReferenceEnd;
  final String? trainCategoryCode;
  final int? brakedWeightPercentage;
  final int? tractionMaxSpeedInKmh;
  final int? hauledLoadMaxSpeedInKmh;
  final int? formationMaxSpeedInKmh;
  final int tractionLengthInCm;
  final int hauledLoadLengthInCm;
  final int formationLengthInCm;
  final int tractionWeightInT;
  final int hauledLoadWeightInT;
  final int formationWeightInT;
  final int tractionBrakedWeightInT;
  final int hauledLoadBrakedWeightInT;
  final int formationBrakedWeightInT;
  final int tractionHoldingForceInHectoNewton;
  final int hauledLoadHoldingForceInHectoNewton;
  final int formationHoldingForceInHectoNewton;
  final bool? brakePositionGForLeadingTraction;
  final bool? brakePositionGForBrakeUnit1to5;
  final bool? brakePositionGForLoadHauled;
  final bool simTrain;
  final List<String> additionalTractions;
  final bool carCarrierVehicle;
  final bool dangerousGoods;
  final int vehiclesCount;
  final int vehiclesWithBrakeDesignLlAndKCount;
  final int vehiclesWithBrakeDesignDCount;
  final int vehiclesWithDisabledBrakesCount;
  final String? europeanVehicleNumberFirst;
  final String? europeanVehicleNumberLast;
  final int axleLoadMaxInKg;
  final String? routeClass;
  final int gradientUphillMaxInPermille;
  final int gradientDownhillMaxInPermille;
  final String? slopeMaxForHoldingForceMinInPermille;

  Map<String, dynamic> toJson() => _$FormationRunToJson(this);
}
