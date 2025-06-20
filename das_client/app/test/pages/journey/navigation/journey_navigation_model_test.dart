import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyNavigationModel', () {
    late JourneyNavigationModel baseTestee;
    late JourneyNavigationModel sameTestee;
    late JourneyNavigationModel diffTrainId;
    late JourneyNavigationModel diffStackLength;
    late JourneyNavigationModel diffIndex;
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
      baseTestee = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      sameTestee = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 1);
      diffTrainId = JourneyNavigationModel(trainIdentification: trainId2, currentIndex: 0, navigationStackLength: 1);
      diffStackLength = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 0, navigationStackLength: 2);
      diffIndex = JourneyNavigationModel(trainIdentification: trainId, currentIndex: 1, navigationStackLength: 1);
    });

    test('equals_whenSameTrainIdAndIndex_thenReturnsTrue', () {
      expect(baseTestee == sameTestee, isTrue);
    });

    test('equals_whenDifferentTrainId_thenReturnsFalse', () {
      expect(baseTestee == diffTrainId, isFalse);
    });

    test('equals_whenDifferentIndex_thenReturnsFalse', () {
      expect(baseTestee == diffIndex, isFalse);
    });

    test('equals_whenDifferentNavigationStackLength_thenReturnsFalse', () {
      expect(baseTestee == diffStackLength, isFalse);
    });

    test('toString_whenCalled_thenReturnsCorrectString', () {
      expect(
        baseTestee.toString(),
        equals('JourneyNavigationModel(trainIdentification: $trainId, currentIndex: 0, navigationStackLength: 1)'),
      );
    });

    test('hashCode_whenSameTrainIdAndIndex_thenReturnsSameHash', () {
      expect(baseTestee.hashCode, equals(sameTestee.hashCode));
    });

    test('hashCode_whenDifferentTrainId_thenReturnsDifferentHash', () {
      expect(baseTestee.hashCode, isNot(equals(diffTrainId.hashCode)));
    });
  });
}
