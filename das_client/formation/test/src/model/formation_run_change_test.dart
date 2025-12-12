import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';

void main() {
  final formationRun = FormationRun(
    inspectionDateTime: DateTime.now(),
    tafTapLocationReferenceStart: 'CH00001',
    tafTapLocationReferenceEnd: 'CH00002',
    tractionLengthInCm: 19,
    hauledLoadLengthInCm: 198,
    formationLengthInCm: 317,
    tractionWeightInT: 90,
    hauledLoadWeightInT: 787,
    formationWeightInT: 877,
    tractionBrakedWeightInT: 58,
    hauledLoadBrakedWeightInT: 682,
    formationBrakedWeightInT: 740,
    tractionHoldingForceInHectoNewton: 56,
    hauledLoadHoldingForceInHectoNewton: 421,
    formationHoldingForceInHectoNewton: 477,
    simTrain: true,
    carCarrierVehicle: true,
    dangerousGoods: true,
    vehiclesCount: 14,
    vehiclesWithBrakeDesignLlAndKCount: 14,
    vehiclesWithBrakeDesignDCount: 0,
    vehiclesWithDisabledBrakesCount: 0,
    axleLoadMaxInKg: 124,
    gradientUphillMaxInPermille: 25,
    gradientDownhillMaxInPermille: 25,
    trainCategoryCode: 'R',
    brakedWeightPercentage: 150,
    tractionMaxSpeedInKmh: 160,
    hauledLoadMaxSpeedInKmh: 100,
    formationMaxSpeedInKmh: 100,
    additionalTractions: ['Q (420)'],
    brakePositionGForBrakeUnit1to5: false,
    brakePositionGForLeadingTraction: true,
    brakePositionGForLoadHauled: false,
    europeanVehicleNumberFirst: 'CH1234567890',
    europeanVehicleNumberLast: 'CH0987654321',
  );

  test('formationRunChange_whenFormationRunsIdentical_thenHasNoChange', () async {
    // ACT
    final testee = FormationRunChange(formationRun: formationRun, previousFormationRun: formationRun);

    // VERIFY
    expect(testee.changesCount, 0);
  });

  test('formationRunChange_whenPreviousFormationRunsIsNull_thenHasNoChange', () async {
    // ACT
    final testee = FormationRunChange(formationRun: formationRun, previousFormationRun: null);

    // VERIFY
    expect(testee.changesCount, 0);
  });

  test('formationRunChange_whenPreviousFormationIsDifferent_thenHasChanges', () async {
    // GIVEN
    final prevFormationRun = FormationRun(
      inspectionDateTime: DateTime.now(),
      tafTapLocationReferenceStart: 'CH00002',
      tafTapLocationReferenceEnd: 'CH00003',
      tractionLengthInCm: 19,
      hauledLoadLengthInCm: 198,
      formationLengthInCm: 317,
      tractionWeightInT: 90,
      hauledLoadWeightInT: 787,
      formationWeightInT: 877,
      tractionBrakedWeightInT: 58,
      hauledLoadBrakedWeightInT: 682,
      formationBrakedWeightInT: 740,
      tractionHoldingForceInHectoNewton: 56,
      hauledLoadHoldingForceInHectoNewton: 421,
      formationHoldingForceInHectoNewton: 477,
      simTrain: false,
      carCarrierVehicle: false,
      dangerousGoods: true,
      vehiclesCount: 16,
      vehiclesWithBrakeDesignLlAndKCount: 14,
      vehiclesWithBrakeDesignDCount: 2,
      vehiclesWithDisabledBrakesCount: 0,
      axleLoadMaxInKg: 124,
      gradientUphillMaxInPermille: 25,
      gradientDownhillMaxInPermille: 25,
      trainCategoryCode: 'A',
      brakedWeightPercentage: 80,
      tractionMaxSpeedInKmh: 160,
      hauledLoadMaxSpeedInKmh: 100,
      formationMaxSpeedInKmh: 100,
      additionalTractions: ['Q (420)', 'X (500)'],
      brakePositionGForBrakeUnit1to5: false,
      brakePositionGForLeadingTraction: true,
      brakePositionGForLoadHauled: false,
      europeanVehicleNumberFirst: 'CH1234567890',
      europeanVehicleNumberLast: 'CH0987654321',
    );

    // ACT
    final testee = FormationRunChange(formationRun: formationRun, previousFormationRun: prevFormationRun);

    // VERIFY
    expect(testee.changesCount, 10);
    expect(testee.hasChanged('additionalTractions'), isTrue);
    expect(testee.hasChanged('brakedWeightPercentage'), isTrue);
    expect(testee.hasChanged('trainCategoryCode'), isTrue);
    expect(testee.hasChanged('simTrain'), isTrue);
    expect(testee.hasChanged('carCarrierVehicle'), isTrue);
    expect(testee.hasChanged('tafTapLocationReferenceStart'), isTrue);
    expect(testee.hasChanged('tafTapLocationReferenceEnd'), isTrue);
    expect(testee.hasChanged('inspectionDateTime'), isTrue);
    expect(testee.hasChanged('vehiclesCount'), isTrue);
    expect(testee.hasChanged('vehiclesWithBrakeDesignDCount'), isTrue);

    expect(testee.hasChanged('europeanVehicleNumberFirst'), isFalse);
    expect(testee.hasChanged('brakePositionGForLeadingTraction'), isFalse);
    expect(testee.hasChanged('hauledLoadBrakedWeightInT'), isFalse);
  });
}
