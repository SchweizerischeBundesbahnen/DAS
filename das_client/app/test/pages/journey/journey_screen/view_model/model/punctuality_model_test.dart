import 'package:app/pages/journey/journey_screen/view_model/model/delay_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  const tenSecondLate = Delay(value: Duration(seconds: 10), location: 'de');
  const tenSecondEarly = Delay(value: Duration(seconds: -10), location: 'de');

  group('PunctualityModel', () {
    group('delay getter', () {
      test('visible_whenGettingDelayString_thenReturnsCorrectValue', () {
        expect(
          DelayModel.visible(delay: tenSecondLate).formattedDelay,
          '+00:10',
        );
      });

      test('stale_whenGettingDelayString_thenReturnsCorrectValue', () {
        expect(
          DelayModel.stale(delay: tenSecondEarly).formattedDelay,
          '-00:10',
        );
      });

      test('hidden_whenGettingDelayString_thenReturnsEmptyString', () {
        expect(DelayModel.hidden().formattedDelay, '');
      });

      test('plannedTimeDeviation_whenPositiveUnderAnHour_thenReturnsCorrectValue', () {
        expect(
          DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: 30)).formattedDelay,
          '+00h30',
        );
      });

      test('plannedTimeDeviation_whenNegative_thenReturnsCorrectValue', () {
        expect(
          DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: -10)).formattedDelay,
          '-00h10',
        );
      });

      test('plannedTimeDeviation_whenOverAnHour_thenReturnsCorrectValue', () {
        expect(
          DelayModel.plannedTimeDeviation(deviation: const Duration(hours: 1, minutes: 30)).formattedDelay,
          '+01h30',
        );
      });

      test('plannedTimeDeviation_whenZero_thenReturnsCorrectValue', () {
        expect(
          DelayModel.plannedTimeDeviation(deviation: Duration.zero).formattedDelay,
          '+00h00',
        );
      });
    });

    group('equality', () {
      test('visible_whenComparedToIdenticalVisible_thenIsEqual', () {
        // ARRANGE
        final model1 = DelayModel.visible(delay: tenSecondLate);
        final model2 = DelayModel.visible(delay: tenSecondLate);

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('visible_whenComparedToDifferentVisible_thenIsNotEqual', () {
        // ARRANGE
        final model1 = DelayModel.visible(delay: tenSecondLate);
        final model2 = DelayModel.visible(delay: tenSecondEarly);

        // EXPECT
        expect(model1 == model2, isFalse);
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('stale_whenComparedToIdenticalStale_thenIsEqual', () {
        // ARRANGE
        final model1 = DelayModel.stale(delay: tenSecondLate);
        final model2 = DelayModel.stale(delay: tenSecondLate);

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('stale_whenComparedToDifferentStale_thenIsNotEqual', () {
        // ARRANGE
        final model1 = DelayModel.stale(delay: tenSecondLate);
        final model2 = DelayModel.stale(delay: tenSecondEarly);

        // EXPECT
        expect(model1 == model2, isFalse);
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('hidden_whenComparedToAnotherHidden_thenIsEqual', () {
        // ARRANGE
        final model1 = DelayModel.hidden();
        final model2 = DelayModel.hidden();

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('differentTypes_whenCompared_thenAreNotEqual', () {
        // ARRANGE
        final visible = DelayModel.visible(delay: tenSecondLate);
        final stale = DelayModel.stale(delay: tenSecondLate);
        final hidden = DelayModel.hidden();
        final plannedTimeDeviation = DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: 10));

        // EXPECT
        expect(visible == stale, isFalse);
        expect(visible == hidden, isFalse);
        expect(stale == hidden, isFalse);
        expect(plannedTimeDeviation == hidden, isFalse);
        expect(plannedTimeDeviation == visible, isFalse);
      });

      test('plannedTimeDeviation_whenComparedToIdentical_thenIsEqual', () {
        // ARRANGE
        final model1 = DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: 10));
        final model2 = DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: 10));

        // EXPECT
        expect(model1 == model2, isTrue);
        expect(model1.hashCode == model2.hashCode, isTrue);
      });

      test('plannedTimeDeviation_whenComparedToDifferent_thenIsNotEqual', () {
        // ARRANGE
        final model1 = DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: 10));
        final model2 = DelayModel.plannedTimeDeviation(deviation: const Duration(minutes: -10));

        // EXPECT
        expect(model1 == model2, isFalse);
        expect(model1.hashCode == model2.hashCode, isFalse);
      });
    });
  });
}
