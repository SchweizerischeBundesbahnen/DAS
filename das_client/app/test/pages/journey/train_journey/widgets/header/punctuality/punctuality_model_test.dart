import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PunctualityModel', () {
    group('delayString getter', () {
      test('visible_whenGettingDelayString_thenReturnsCorrectValue', () {
        expect(PunctualityModel.visible(delayString: 'someStr').delayString, 'someStr');
      });

      test('stale_whenGettingDelayString_thenReturnsCorrectValue', () {
        expect(PunctualityModel.stale(delayString: 'someStr').delayString, 'someStr');
      });

      test('hidden_whenGettingDelayString_thenReturnsEmptyString', () {
        expect(PunctualityModel.hidden().delayString, '');
      });
    });

    group('equality', () {
      test('visible_whenComparedToIdenticalVisible_thenIsEqual', () {
        // ARRANGE
        final model1 = PunctualityModel.visible(delayString: '+00:00');
        final model2 = PunctualityModel.visible(delayString: '+00:00');

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('visible_whenComparedToDifferentVisible_thenIsNotEqual', () {
        // ARRANGE
        final model1 = PunctualityModel.visible(delayString: '+00:00');
        final model2 = PunctualityModel.visible(delayString: '+00:10');

        // EXPECT
        expect(model1 == model2, isFalse);
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('stale_whenComparedToIdenticalStale_thenIsEqual', () {
        // ARRANGE
        final model1 = PunctualityModel.stale(delayString: '+00:00');
        final model2 = PunctualityModel.stale(delayString: '+00:00');

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('stale_whenComparedToDifferentStale_thenIsNotEqual', () {
        // ARRANGE
        final model1 = PunctualityModel.stale(delayString: '+00:00');
        final model2 = PunctualityModel.stale(delayString: '+01:00');

        // EXPECT
        expect(model1 == model2, isFalse);
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('hidden_whenComparedToAnotherHidden_thenIsEqual', () {
        // ARRANGE
        final model1 = PunctualityModel.hidden();
        final model2 = PunctualityModel.hidden();

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('differentTypes_whenCompared_thenAreNotEqual', () {
        // ARRANGE
        final visible = PunctualityModel.visible(delayString: '+01:00');
        final stale = PunctualityModel.stale(delayString: '+01:00');
        final hidden = PunctualityModel.hidden();

        // EXPECT
        expect(visible == stale, isFalse);
        expect(visible == hidden, isFalse);
        expect(stale == hidden, isFalse);
      });
    });
  });
}
