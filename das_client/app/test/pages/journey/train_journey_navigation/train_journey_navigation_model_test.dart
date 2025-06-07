import 'package:app/pages/journey/train_journey_navigation/train_journey_navigation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('TrainJourneyNavigationModel', () {
    late TrainJourneyNavigationModel testee1;
    late TrainJourneyNavigationModel testee2;
    late TrainJourneyNavigationModel testee3;
    late TrainJourneyNavigationModel testee4;
    late TrainIdentification trainId;
    late TrainIdentification trainId2;

    setUp(() {
      trainId = TrainIdentification(
        ru: RailwayUndertaking.sbbP,
        trainNumber: '1234',
        date: DateTime.now(),
      );
      trainId2 = TrainIdentification(
        ru: RailwayUndertaking.sbbC,
        trainNumber: '5678',
        date: DateTime.now().add(Duration(days: 1)),
      );
      testee1 = TrainJourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      testee2 = TrainJourneyNavigationModel(trainIdentification: trainId2, currentIndex: 1, navigationStackLength: 2);
      testee3 = TrainJourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      testee4 = TrainJourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 2);
    });

    test('equals_whenSameTrainIdAndIndex_thenReturnsTrue', () {
      expect(testee1 == testee3, isTrue);
    });

    test('equals_whenDifferentTrainId_thenReturnsFalse', () {
      expect(testee1 == testee2, isFalse);
    });

    test('equals_whenDifferentIndex_thenReturnsFalse', () {
      expect(testee1 == testee2, isFalse);
    });

    test('equals_whenDifferentNavigationStackLength_thenReturnsFalse', () {
      expect(testee1 == testee4, isFalse);
    });

    test('toString_whenCalled_thenReturnsCorrectString', () {
      expect(
        testee1.toString(),
        equals('TrainJourneyNavigationModel(trainIdentification: $trainId, currentIndex: 0, navigationStackLength: 1)'),
      );
    });

    test('hashCode_whenSameTrainIdAndIndex_thenReturnsSameHash', () {
      expect(testee1.hashCode, equals(testee3.hashCode));
    });

    test('hashCode_whenDifferentTrainId_thenReturnsDifferentHash', () {
      expect(testee1.hashCode, isNot(equals(testee2.hashCode)));
    });
  });
}
