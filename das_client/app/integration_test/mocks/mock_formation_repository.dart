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
}
