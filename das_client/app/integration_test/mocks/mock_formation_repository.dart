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
