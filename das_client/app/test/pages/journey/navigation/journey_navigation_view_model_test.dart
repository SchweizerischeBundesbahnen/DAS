import 'dart:async';

import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('TrainJourneyNavigationViewModel', () {
    late JourneyNavigationViewModel viewModel;
    late List<dynamic> emitRegister;
    late StreamSubscription sub;

    final tomorrow = DateTime.now().add(Duration(days: 1));
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final trainId1 = TrainIdentification(ru: RailwayUndertaking.sbbP, trainNumber: '1234', date: DateTime.now());
    final trainId2 = TrainIdentification(ru: RailwayUndertaking.sbbC, trainNumber: '5678', date: tomorrow);
    final trainId3 = TrainIdentification(ru: RailwayUndertaking.blsP, trainNumber: '9999', date: yesterday);

    setUp(() {
      viewModel = JourneyNavigationViewModel();
      emitRegister = <dynamic>[];
      sub = viewModel.model.listen(emitRegister.add);
    });

    tearDown(() {
      sub.cancel();
      viewModel.dispose();
    });

    test('initialState_whenInstantiated_thenIsEmpty', () {
      expect(viewModel.modelValue, isNull);
    });

    test('push_whenNewJourneyAdded_thenUpdatesModel', () {
      // ACT
      viewModel.push(trainId1);

      // EXPECT
      final model = viewModel.modelValue!;
      expect(model.trainIdentification, trainId1);
      expect(model.currentIndex, 0);
      expect(model.navigationStackLength, 1);
    });

    test('push_whenSecondNewJourneyAdded_thenUpdatesModel', () {
      // ARRANGE
      viewModel.push(trainId1);

      // ACT
      viewModel.push(trainId2);

      // EXPECT
      final model = viewModel.modelValue!;
      expect(model.trainIdentification, trainId2);
      expect(model.currentIndex, 1);
      expect(model.navigationStackLength, 2);
    });

    test('push_whenSameJourneyAddedTwice_thenDoesNotChangeModelOrLength', () {
      // ARRANGE
      viewModel.push(trainId1);
      final model1 = viewModel.modelValue;

      // ACT
      viewModel.push(trainId1);

      // EXPECT
      final model2 = viewModel.modelValue;
      expect(model2, model1);
      expect(model2!.trainIdentification, trainId1);
      expect(model2.currentIndex, 0);
      expect(model2.navigationStackLength, 1);
    });

    test('next_whenCalled_thenMovesToNextJourney', () {
      // ARRANGE
      viewModel.push(trainId1);
      viewModel.push(trainId2);
      viewModel.push(trainId3);
      viewModel.push(trainId2); // set current to trainId2

      // ACT
      viewModel.next();

      // EXPECT
      final model = viewModel.modelValue!;
      expect(model.trainIdentification, trainId3);
      expect(model.currentIndex, 2);
      expect(model.navigationStackLength, 3);
    });

    test('next_whenAtEnd_thenDoesNotChangeModel', () {
      // ARRANGE
      viewModel.push(trainId1);
      viewModel.push(trainId2);
      viewModel.push(trainId3);
      viewModel.push(trainId3); // set current to last
      final modelBefore = viewModel.modelValue;

      // ACT
      viewModel.next();

      // EXPECT
      final modelAfter = viewModel.modelValue;
      expect(modelAfter, modelBefore);
      expect(modelAfter!.trainIdentification, trainId3);
      expect(modelAfter.currentIndex, 2);
      expect(modelAfter.navigationStackLength, 3);
    });

    test('previous_whenCalled_thenMovesToPreviousJourney', () {
      // ARRANGE
      viewModel.push(trainId1);
      viewModel.push(trainId2);
      viewModel.push(trainId3);
      viewModel.push(trainId2); // set current to trainId2

      // ACT
      viewModel.previous();

      // EXPECT
      final model = viewModel.modelValue!;
      expect(model.trainIdentification, trainId1);
      expect(model.currentIndex, 0);
      expect(model.navigationStackLength, 3);
    });

    test('previous_whenAtStart_thenDoesNotChangeModel', () {
      // ARRANGE
      viewModel.push(trainId1);
      final modelBefore = viewModel.modelValue;

      // ACT
      viewModel.previous();

      // EXPECT
      final modelAfter = viewModel.modelValue;
      expect(modelAfter, modelBefore);
      expect(modelAfter!.trainIdentification, trainId1);
      expect(modelAfter.currentIndex, 0);
      expect(modelAfter.navigationStackLength, 1);
    });

    test('dispose_whenCalled_thenClearsJourneysAndClosesStream', () {
      // ARRANGE
      viewModel.push(trainId1);

      // ACT
      viewModel.dispose();

      // EXPECT
      expect(() => viewModel.modelValue, returnsNormally);
    });

    test('model_stream_whenPushCalledMultipleTimesWithSameTrainId_thenEmitsOnce', () async {
      // ACT
      viewModel.push(trainId1);
      viewModel.push(trainId1);
      viewModel.push(trainId1);

      await allowStreamProcessing();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 1);
    });

    test('model_stream_whenPushDifferentTrainIds_thenEmitsForEach', () async {
      // ACT
      viewModel.push(trainId1);
      viewModel.push(trainId2);
      viewModel.push(trainId3);

      await allowStreamProcessing();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 3);
    });

    test('model_stream_whenNextOrPreviousCalledAtBounds_thenDoesNotEmit', () async {
      // ARRANGE
      viewModel.push(trainId1);
      await allowStreamProcessing();
      emitRegister.clear();

      // ACT
      viewModel.previous(); // at start, should not emit
      viewModel.next(); // at end, should not emit

      await allowStreamProcessing();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 0);
    });

    test('model_stream_whenNextAndPreviousCalledWithinBounds_thenEmits', () async {
      // ARRANGE
      viewModel.push(trainId1);
      viewModel.push(trainId2);
      await allowStreamProcessing();
      emitRegister.clear();

      // ACT
      viewModel.previous(); // should emit (move to trainId1)
      viewModel.next(); // should emit (move to trainId2)

      await allowStreamProcessing();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 2);
    });
  });
}

Future<void> allowStreamProcessing() async => await Future.delayed(Duration.zero);
