import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyNavigationModel', () {
    late JourneyNavigationModel testee1;
    late JourneyNavigationModel testee2;
    late JourneyNavigationModel testee3;
    late JourneyNavigationModel testee4;
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
      testee1 = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      testee2 = JourneyNavigationModel(trainIdentification: trainId2, currentIndex: 1, navigationStackLength: 2);
      testee3 = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      testee4 = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 2);
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
        equals('JourneyNavigationModel(trainIdentification: $trainId, currentIndex: 0, navigationStackLength: 1)'),
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
