import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/model/journey_navigation_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JourneyNavigationModel', () {
    late JourneyNavigationModel baseTestee;
    late JourneyNavigationModel sameTestee;
    late JourneyNavigationModel diffTrainId;
    late JourneyNavigationModel diffStackLength;
    late JourneyNavigationModel diffIndex;
    late JourneyNavigationModel diffShowNavigationButtons;
    late ExtendedTrainIdentification trainId;
    late ExtendedTrainIdentification trainId2;

    setUp(() {
      trainId = ExtendedTrainIdentification(
        trainIdentification: TrainIdentification(
          companyCode: '1285',
          trainNumber: '1234',
          date: DateTime.now(),
        ),
      );
      trainId2 = ExtendedTrainIdentification(
        trainIdentification: TrainIdentification(
          companyCode: '2185',
          trainNumber: '5678',
          date: DateTime.now().add(Duration(days: 1)),
        ),
      );
      baseTestee = JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: false,
      );
      sameTestee = JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: false,
      );
      diffTrainId = JourneyNavigationModel(
        trainIdentification: trainId2,
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: false,
      );
      diffStackLength = JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: 0,
        navigationStackLength: 2,
        showNavigationButtons: false,
      );
      diffIndex = JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: 1,
        navigationStackLength: 1,
        showNavigationButtons: false,
      );
      diffShowNavigationButtons = JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: true,
      );
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

    test('equals_whenDifferentShowNavigationButtons_thenReturnsFalse', () {
      expect(baseTestee == diffShowNavigationButtons, isFalse);
    });

    test('toString_whenCalled_thenReturnsCorrectString', () {
      final expectedString =
          'JourneyNavigationModel{trainIdentification: $trainId, currentIndex: 0, '
          'navigationStackLength: 1, showNavigationButtons: false}';
      expect(baseTestee.toString(), equals(expectedString));
    });

    test('hashCode_whenSameTrainIdAndIndex_thenReturnsSameHash', () {
      expect(baseTestee.hashCode, equals(sameTestee.hashCode));
    });

    test('hashCode_whenDifferentTrainId_thenReturnsDifferentHash', () {
      expect(baseTestee.hashCode, isNot(equals(diffTrainId.hashCode)));
    });
  });
}
