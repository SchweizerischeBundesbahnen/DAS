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
    expect(testee.hasChanged(.additionalTractions), isTrue);
    expect(testee.hasChanged(.brakedWeightPercentage), isTrue);
    expect(testee.hasChanged(.trainCategoryCode), isTrue);
    expect(testee.hasChanged(.simTrain), isTrue);
    expect(testee.hasChanged(.carCarrierVehicle), isTrue);
    expect(testee.hasChanged(.tafTapLocationReferenceStart), isTrue);
    expect(testee.hasChanged(.tafTapLocationReferenceEnd), isTrue);
    expect(testee.hasChanged(.inspectionDateTime), isTrue);
    expect(testee.hasChanged(.vehiclesCount), isTrue);
    expect(testee.hasChanged(.vehiclesWithBrakeDesignDCount), isTrue);

    expect(testee.hasChanged(.europeanVehicleNumberFirst), isFalse);
    expect(testee.hasChanged(.brakePositionGForLeadingTraction), isFalse);
    expect(testee.hasChanged(.hauledLoadBrakedWeightInT), isFalse);
  });

  test('formationRunChange_whenAllFieldsAreDifferent_thenHasAllChanges', () async {
    final now = DateTime.now();

    // ACT
    final testee = FormationRunChange(
      formationRun: FormationRun(
        inspectionDateTime: now,
        tafTapLocationReferenceStart: 'CH09991',
        tafTapLocationReferenceEnd: 'CH09992',
        tractionLengthInCm: 20,
        hauledLoadLengthInCm: 200,
        formationLengthInCm: 320,
        tractionWeightInT: 95,
        hauledLoadWeightInT: 800,
        formationWeightInT: 895,
        tractionBrakedWeightInT: 60,
        hauledLoadBrakedWeightInT: 690,
        formationBrakedWeightInT: 750,
        tractionHoldingForceInHectoNewton: 58,
        hauledLoadHoldingForceInHectoNewton: 430,
        formationHoldingForceInHectoNewton: 488,
        simTrain: true,
        carCarrierVehicle: true,
        dangerousGoods: true,
        vehiclesCount: 15,
        vehiclesWithBrakeDesignLlAndKCount: 15,
        vehiclesWithBrakeDesignDCount: 0,
        vehiclesWithDisabledBrakesCount: 1,
        axleLoadMaxInKg: 130,
        gradientUphillMaxInPermille: 30,
        gradientDownhillMaxInPermille: 30,
        trainCategoryCode: 'R',
        brakedWeightPercentage: 150,
        tractionMaxSpeedInKmh: 170,
        hauledLoadMaxSpeedInKmh: 110,
        formationMaxSpeedInKmh: 110,
        additionalTractions: ['Q (420)', 'Z (500)'],
      ),
      previousFormationRun: FormationRun(
        inspectionDateTime: now.add(Duration(seconds: 3)),
        tafTapLocationReferenceStart: 'CH09995',
        tafTapLocationReferenceEnd: 'CH09996',
        tractionLengthInCm: 30,
        hauledLoadLengthInCm: 220,
        formationLengthInCm: 350,
        tractionWeightInT: 100,
        hauledLoadWeightInT: 900,
        formationWeightInT: 995,
        tractionBrakedWeightInT: 80,
        hauledLoadBrakedWeightInT: 890,
        formationBrakedWeightInT: 950,
        tractionHoldingForceInHectoNewton: 78,
        hauledLoadHoldingForceInHectoNewton: 530,
        formationHoldingForceInHectoNewton: 688,
        simTrain: false,
        carCarrierVehicle: false,
        dangerousGoods: false,
        vehiclesCount: 21,
        vehiclesWithBrakeDesignLlAndKCount: 14,
        vehiclesWithBrakeDesignDCount: 2,
        vehiclesWithDisabledBrakesCount: 5,
        axleLoadMaxInKg: 170,
        gradientUphillMaxInPermille: 20,
        gradientDownhillMaxInPermille: 15,
        trainCategoryCode: 'A',
        brakedWeightPercentage: 85,
        tractionMaxSpeedInKmh: 190,
        hauledLoadMaxSpeedInKmh: 150,
        formationMaxSpeedInKmh: 150,
        additionalTractions: [],
        europeanVehicleNumberFirst: 'CH1234567890',
        europeanVehicleNumberLast: 'CH0987654321',
        brakePositionGForBrakeUnit1to5: true,
        brakePositionGForLeadingTraction: true,
        brakePositionGForLoadHauled: true,
        routeClass: 'ABC',
        slopeMaxForHoldingForceMinInPermille: '20',
      ),
    );

    // VERIFY
    expect(testee.changesCount, 38);
    for (final field in FormationRunFields.values) {
      expect(testee.hasChanged(field), isTrue);
    }
  });

  test('hasInspectionDateChanged_whenDateIsDifferent_thenIsTrue', () async {
    // GIVEN
    final prevFormationRun = FormationRun(
      inspectionDateTime: DateTime.now().add(Duration(days: -1)),
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
    );

    // ACT
    final testee = FormationRunChange(formationRun: formationRun, previousFormationRun: prevFormationRun);

    // VERIFY
    expect(testee.hasChanged(.inspectionDateTime), isTrue);
    expect(testee.hasInspectionDateChanged(), isTrue);
  });

  test('hasInspectionDateChanged_whenOnlyTimeIsDifferent_thenIsFalse', () async {
    final year = 2025;
    final month = 5;
    final day = 15;

    // GIVEN
    final currentFormationRun = FormationRun(
      inspectionDateTime: DateTime(year, month, day, 10, 30, 0),
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
    );
    final prevFormationRun = FormationRun(
      inspectionDateTime: DateTime(year, month, day, 11, 30, 0),
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
    );

    // ACT
    final testee = FormationRunChange(formationRun: currentFormationRun, previousFormationRun: prevFormationRun);

    // VERIFY
    expect(testee.hasChanged(.inspectionDateTime), isTrue);
    expect(testee.hasInspectionDateChanged(), isFalse);
  });
}
