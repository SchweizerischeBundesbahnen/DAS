import 'package:formation/component.dart';
import 'package:rxdart/rxdart.dart';

class MockFormationRepository implements FormationRepository {
  BehaviorSubject<Formation?> formationSubject = BehaviorSubject<Formation?>.seeded(null);

  MockFormationRepository();

  @override
  Stream<Formation?> watchFormation({
    required String operationalTrainNumber,
    required String company,
    required DateTime operationalDay,
  }) {
    return formationSubject.stream;
  }

  void emitNull() {
    formationSubject.add(null);
  }

  void emitT9999Formation() {
    final formation = Formation(
      operationalTrainNumber: 'T9999',
      company: '2185',
      operationalDay: DateTime.now(),
      formationRuns: [
        _generateFormationRun(
          'CH09991',
          'CH09992',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 30,
        ),
        _generateFormationRun(
          'CH09992',
          'CH09993',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          simTrain: true,
        ),
        _generateFormationRun(
          'CH09993',
          'CH09994',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          dangerousGoods: true,
        ),
        _generateFormationRun(
          'CH09994',
          'CH09995',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          dangerousGoods: true,
          simTrain: true,
        ),
        _generateFormationRun(
          'CH09995',
          'CH09996',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          carCarrier: true,
        ),
      ],
    );
    formationSubject.add(formation);
  }

  void emitFormationWithAllChanges() {
    final now = DateTime.now();

    final formation = Formation(
      operationalTrainNumber: 'T9999',
      company: '2185',
      operationalDay: now,
      formationRuns: [
        FormationRun(
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
        FormationRun(
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
      ],
    );
    formationSubject.add(formation);
  }

  void emitT9999FormationUpdate() {
    final formation = Formation(
      operationalTrainNumber: 'T9999',
      company: '2185',
      operationalDay: DateTime.now(),
      formationRuns: [
        _generateFormationRun(
          'CH09991',
          'CH09992',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
        ),
        _generateFormationRun(
          'CH09992',
          'CH09993',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          simTrain: true,
        ),
        _generateFormationRun(
          'CH09993',
          'CH09994',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          dangerousGoods: true,
        ),
        _generateFormationRun(
          'CH09994',
          'CH09995',
          trainCategoryCode: 'A',
          brakedWeightPercentage: 95,
          dangerousGoods: true,
          simTrain: true,
        ),
      ],
    );
    formationSubject.add(formation);
  }

  FormationRun _generateFormationRun(
    String tafTapStart,
    String tafTapEnd, {
    String? trainCategoryCode,
    int? brakedWeightPercentage,
    bool simTrain = false,
    bool dangerousGoods = false,
    bool carCarrier = false,
  }) {
    return FormationRun(
      inspectionDateTime: DateTime.now(),
      tafTapLocationReferenceStart: tafTapStart,
      tafTapLocationReferenceEnd: tafTapEnd,
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
      simTrain: simTrain,
      carCarrierVehicle: carCarrier,
      dangerousGoods: dangerousGoods,
      vehiclesCount: 14,
      vehiclesWithBrakeDesignLlAndKCount: 14,
      vehiclesWithBrakeDesignDCount: 0,
      vehiclesWithDisabledBrakesCount: 0,
      axleLoadMaxInKg: 124,
      gradientUphillMaxInPermille: 25,
      gradientDownhillMaxInPermille: 25,
      trainCategoryCode: trainCategoryCode,
      brakedWeightPercentage: brakedWeightPercentage,
      tractionMaxSpeedInKmh: 160,
      hauledLoadMaxSpeedInKmh: 100,
      formationMaxSpeedInKmh: 100,
      additionalTractions: ['Q (420)'],
    );
  }

  @override
  Future<Formation?> loadFormation(String operationalTrainNumber, String company, DateTime operationalDay) async {
    return formationSubject.value;
  }
}
