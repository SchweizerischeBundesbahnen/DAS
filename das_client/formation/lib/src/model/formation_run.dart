import 'package:collection/collection.dart';
import 'package:formation/src/api/converter/local_data_time_converter.dart';
import 'package:formation/src/model/transport_paper_link.dart';
import 'package:json_annotation/json_annotation.dart';

part 'formation_run.g.dart';

@JsonSerializable()
class FormationRun({
  @LocalDataTimeConverter() required final DateTime inspectionDateTime,
  required final String tafTapLocationReferenceStart,
  required final String tafTapLocationReferenceEnd,
  required final int tractionLengthInCm,
  required final int hauledLoadLengthInCm,
  required final int formationLengthInCm,
  required final int tractionWeightInT,
  required final int hauledLoadWeightInT,
  required final int formationWeightInT,
  required final int tractionBrakedWeightInT,
  required final int hauledLoadBrakedWeightInT,
  required final int formationBrakedWeightInT,
  required final int tractionHoldingForceInHectoNewton,
  required final int formationHoldingForceInHectoNewton,
  required final bool simTrain,
  required final bool carCarrierVehicle,
  required final bool dangerousGoods,
  required final int vehiclesCount,
  required final int vehiclesWithBrakeDesignLAndLlAndKCount,
  required final int vehiclesWithBrakeDesignDCount,
  required final int vehiclesWithDisabledBrakesCount,
  required final int axleLoadMaxInKg,
  required final int gradientUphillMaxInPermille,
  required final int gradientDownhillMaxInPermille,
  final int? hauledLoadHoldingForceInHectoNewton,
  final String? trainCategoryCode,
  final int? brakedWeightPercentage,
  final int? tractionMaxSpeedInKmh,
  final int? hauledLoadMaxSpeedInKmh,
  final int? formationMaxSpeedInKmh,
  final bool? brakePositionGForLeadingTraction,
  final bool? brakePositionGForBrakeUnit1to5,
  final bool? brakePositionGForLoadHauled,
  final List<String> additionalTractions = const [],
  final String? europeanVehicleNumberFirst,
  final String? europeanVehicleNumberLast,
  final String? routeClass,
  final String? slopeMaxForHoldingForceMinInPermille,
  final TransportPaperLink? transportPaperLink,
}) {
  factory FormationRun.fromJson(Map<String, dynamic> json) {
    return _$FormationRunFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FormationRunToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormationRun &&
          runtimeType == other.runtimeType &&
          inspectionDateTime == other.inspectionDateTime &&
          tafTapLocationReferenceStart == other.tafTapLocationReferenceStart &&
          tafTapLocationReferenceEnd == other.tafTapLocationReferenceEnd &&
          trainCategoryCode == other.trainCategoryCode &&
          brakedWeightPercentage == other.brakedWeightPercentage &&
          tractionMaxSpeedInKmh == other.tractionMaxSpeedInKmh &&
          hauledLoadMaxSpeedInKmh == other.hauledLoadMaxSpeedInKmh &&
          formationMaxSpeedInKmh == other.formationMaxSpeedInKmh &&
          tractionLengthInCm == other.tractionLengthInCm &&
          hauledLoadLengthInCm == other.hauledLoadLengthInCm &&
          formationLengthInCm == other.formationLengthInCm &&
          tractionWeightInT == other.tractionWeightInT &&
          hauledLoadWeightInT == other.hauledLoadWeightInT &&
          formationWeightInT == other.formationWeightInT &&
          tractionBrakedWeightInT == other.tractionBrakedWeightInT &&
          hauledLoadBrakedWeightInT == other.hauledLoadBrakedWeightInT &&
          formationBrakedWeightInT == other.formationBrakedWeightInT &&
          tractionHoldingForceInHectoNewton == other.tractionHoldingForceInHectoNewton &&
          hauledLoadHoldingForceInHectoNewton == other.hauledLoadHoldingForceInHectoNewton &&
          formationHoldingForceInHectoNewton == other.formationHoldingForceInHectoNewton &&
          brakePositionGForLeadingTraction == other.brakePositionGForLeadingTraction &&
          brakePositionGForBrakeUnit1to5 == other.brakePositionGForBrakeUnit1to5 &&
          brakePositionGForLoadHauled == other.brakePositionGForLoadHauled &&
          simTrain == other.simTrain &&
          ListEquality().equals(additionalTractions, other.additionalTractions) &&
          carCarrierVehicle == other.carCarrierVehicle &&
          dangerousGoods == other.dangerousGoods &&
          vehiclesCount == other.vehiclesCount &&
          vehiclesWithBrakeDesignLAndLlAndKCount == other.vehiclesWithBrakeDesignLAndLlAndKCount &&
          vehiclesWithBrakeDesignDCount == other.vehiclesWithBrakeDesignDCount &&
          vehiclesWithDisabledBrakesCount == other.vehiclesWithDisabledBrakesCount &&
          europeanVehicleNumberFirst == other.europeanVehicleNumberFirst &&
          europeanVehicleNumberLast == other.europeanVehicleNumberLast &&
          axleLoadMaxInKg == other.axleLoadMaxInKg &&
          routeClass == other.routeClass &&
          gradientUphillMaxInPermille == other.gradientUphillMaxInPermille &&
          gradientDownhillMaxInPermille == other.gradientDownhillMaxInPermille &&
          slopeMaxForHoldingForceMinInPermille == other.slopeMaxForHoldingForceMinInPermille &&
          transportPaperLink == other.transportPaperLink;

  @override
  int get hashCode => Object.hashAll([
    inspectionDateTime,
    tafTapLocationReferenceStart,
    tafTapLocationReferenceEnd,
    trainCategoryCode,
    brakedWeightPercentage,
    tractionMaxSpeedInKmh,
    hauledLoadMaxSpeedInKmh,
    formationMaxSpeedInKmh,
    tractionLengthInCm,
    hauledLoadLengthInCm,
    formationLengthInCm,
    tractionWeightInT,
    hauledLoadWeightInT,
    formationWeightInT,
    tractionBrakedWeightInT,
    hauledLoadBrakedWeightInT,
    formationBrakedWeightInT,
    tractionHoldingForceInHectoNewton,
    hauledLoadHoldingForceInHectoNewton,
    formationHoldingForceInHectoNewton,
    brakePositionGForLeadingTraction,
    brakePositionGForBrakeUnit1to5,
    brakePositionGForLoadHauled,
    simTrain,
    additionalTractions,
    carCarrierVehicle,
    dangerousGoods,
    vehiclesCount,
    vehiclesWithBrakeDesignLAndLlAndKCount,
    vehiclesWithBrakeDesignDCount,
    vehiclesWithDisabledBrakesCount,
    europeanVehicleNumberFirst,
    europeanVehicleNumberLast,
    axleLoadMaxInKg,
    routeClass,
    gradientUphillMaxInPermille,
    gradientDownhillMaxInPermille,
    slopeMaxForHoldingForceMinInPermille,
    transportPaperLink,
  ]);

  @override
  String toString() {
    return 'FormationRun{inspectionDateTime: $inspectionDateTime, '
        'tafTapLocationReferenceStart: $tafTapLocationReferenceStart, '
        'tafTapLocationReferenceEnd: $tafTapLocationReferenceEnd, '
        'trainCategoryCode: $trainCategoryCode, '
        'brakedWeightPercentage: $brakedWeightPercentage, '
        'tractionMaxSpeedInKmh: $tractionMaxSpeedInKmh, '
        'hauledLoadMaxSpeedInKmh: $hauledLoadMaxSpeedInKmh, '
        'formationMaxSpeedInKmh: $formationMaxSpeedInKmh, '
        'tractionLengthInCm: $tractionLengthInCm, '
        'hauledLoadLengthInCm: $hauledLoadLengthInCm, '
        'formationLengthInCm: $formationLengthInCm, '
        'tractionWeightInT: $tractionWeightInT, '
        'hauledLoadWeightInT: $hauledLoadWeightInT, '
        'formationWeightInT: $formationWeightInT, '
        'tractionBrakedWeightInT: $tractionBrakedWeightInT, '
        'hauledLoadBrakedWeightInT: $hauledLoadBrakedWeightInT, '
        'formationBrakedWeightInT: $formationBrakedWeightInT, '
        'tractionHoldingForceInHectoNewton: $tractionHoldingForceInHectoNewton, '
        'hauledLoadHoldingForceInHectoNewton: $hauledLoadHoldingForceInHectoNewton, '
        'formationHoldingForceInHectoNewton: $formationHoldingForceInHectoNewton, '
        'brakePositionGForLeadingTraction: $brakePositionGForLeadingTraction, '
        'brakePositionGForBrakeUnit1to5: $brakePositionGForBrakeUnit1to5, '
        'brakePositionGForLoadHauled: $brakePositionGForLoadHauled, '
        'simTrain: $simTrain, '
        'additionalTractions: $additionalTractions, '
        'carCarrierVehicle: $carCarrierVehicle, '
        'dangerousGoods: $dangerousGoods, '
        'vehiclesCount: $vehiclesCount, '
        'vehiclesWithBrakeDesignLAndLlAndKCount: $vehiclesWithBrakeDesignLAndLlAndKCount, '
        'vehiclesWithBrakeDesignDCount: $vehiclesWithBrakeDesignDCount, '
        'vehiclesWithDisabledBrakesCount: $vehiclesWithDisabledBrakesCount, '
        'europeanVehicleNumberFirst: $europeanVehicleNumberFirst, '
        'europeanVehicleNumberLast: $europeanVehicleNumberLast, '
        'axleLoadMaxInKg: $axleLoadMaxInKg, '
        'routeClass: $routeClass, '
        'gradientUphillMaxInPermille: $gradientUphillMaxInPermille, '
        'gradientDownhillMaxInPermille: $gradientDownhillMaxInPermille, '
        'slopeMaxForHoldingForceMinInPermille: $slopeMaxForHoldingForceMinInPermille, '
        'transportPaperLink: $transportPaperLink,}';
  }
}

enum FormationRunFields {
  inspectionDateTime('inspectionDateTime'),
  tafTapLocationReferenceStart('tafTapLocationReferenceStart'),
  tafTapLocationReferenceEnd('tafTapLocationReferenceEnd'),
  trainCategoryCode('trainCategoryCode'),
  brakedWeightPercentage('brakedWeightPercentage'),
  tractionMaxSpeedInKmh('tractionMaxSpeedInKmh'),
  hauledLoadMaxSpeedInKmh('hauledLoadMaxSpeedInKmh'),
  formationMaxSpeedInKmh('formationMaxSpeedInKmh'),
  tractionLengthInCm('tractionLengthInCm'),
  hauledLoadLengthInCm('hauledLoadLengthInCm'),
  formationLengthInCm('formationLengthInCm'),
  tractionWeightInT('tractionWeightInT'),
  hauledLoadWeightInT('hauledLoadWeightInT'),
  formationWeightInT('formationWeightInT'),
  tractionBrakedWeightInT('tractionBrakedWeightInT'),
  hauledLoadBrakedWeightInT('hauledLoadBrakedWeightInT'),
  formationBrakedWeightInT('formationBrakedWeightInT'),
  tractionHoldingForceInHectoNewton('tractionHoldingForceInHectoNewton'),
  hauledLoadHoldingForceInHectoNewton('hauledLoadHoldingForceInHectoNewton'),
  formationHoldingForceInHectoNewton('formationHoldingForceInHectoNewton'),
  brakePositionGForLeadingTraction('brakePositionGForLeadingTraction'),
  brakePositionGForBrakeUnit1to5('brakePositionGForBrakeUnit1to5'),
  brakePositionGForLoadHauled('brakePositionGForLoadHauled'),
  simTrain('simTrain'),
  additionalTractions('additionalTractions'),
  carCarrierVehicle('carCarrierVehicle'),
  dangerousGoods('dangerousGoods'),
  vehiclesCount('vehiclesCount'),
  vehiclesWithBrakeDesignLAndLlAndKCount('vehiclesWithBrakeDesignLAndLlAndKCount'),
  vehiclesWithBrakeDesignDCount('vehiclesWithBrakeDesignDCount'),
  vehiclesWithDisabledBrakesCount('vehiclesWithDisabledBrakesCount'),
  europeanVehicleNumberFirst('europeanVehicleNumberFirst'),
  europeanVehicleNumberLast('europeanVehicleNumberLast'),
  axleLoadMaxInKg('axleLoadMaxInKg'),
  routeClass('routeClass'),
  gradientUphillMaxInPermille('gradientUphillMaxInPermille'),
  gradientDownhillMaxInPermille('gradientDownhillMaxInPermille'),
  slopeMaxForHoldingForceMinInPermille('slopeMaxForHoldingForceMinInPermille');

  FormationRunFields(this.fieldName);

  final String fieldName;
}
