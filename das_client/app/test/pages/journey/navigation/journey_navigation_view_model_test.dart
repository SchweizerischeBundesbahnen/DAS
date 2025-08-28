import 'dart:async';

import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';
import 'journey_navigation_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SferaRemoteRepo>()])
void main() {
  group('JourneyNavigationViewModel', () {
    late JourneyNavigationViewModel testee;
    late List<dynamic> emitRegister;
    late StreamSubscription sub;
    late MockSferaRemoteRepo mockSferaRepo;
    late BehaviorSubject<SferaRemoteRepositoryState> mockStream;

    final now = DateTime(1970, 1, 1);
    final tomorrow = now.add(Duration(days: 1));
    final yesterday = now.subtract(Duration(days: 1));
    final trainId1 = TrainIdentification(ru: RailwayUndertaking.sbbP, trainNumber: '1234', date: now);
    final trainId2 = TrainIdentification(ru: RailwayUndertaking.sbbC, trainNumber: '5678', date: tomorrow);
    final trainId3 = TrainIdentification(ru: RailwayUndertaking.blsP, trainNumber: '9999', date: yesterday);

    setUp(() {
      mockSferaRepo = MockSferaRemoteRepo();
      mockStream = BehaviorSubject<SferaRemoteRepositoryState>.seeded(SferaRemoteRepositoryState.disconnected);
      when(mockSferaRepo.stateStream).thenAnswer((_) => mockStream.stream);
      testee = JourneyNavigationViewModel(sferaRepo: mockSferaRepo);
      emitRegister = <dynamic>[];
      sub = testee.model.listen(emitRegister.add);
    });

    tearDown(() {
      sub.cancel();
      if (testee.modelValue != null) testee.dispose();
    });

    test('initialState_whenInstantiated_thenIsEmpty', () {
      expect(testee.modelValue, isNull);
    });

    test('push_whenNewJourneyAdded_thenUpdatesModel', () async {
      // ACT
      await testee.push(trainId1);

      // EXPECT
      final model = testee.modelValue!;
      expect(model.trainIdentification, trainId1);
      expect(model.currentIndex, 0);
      expect(model.navigationStackLength, 1);
    });

    test('push_whenSecondNewJourneyAdded_thenUpdatesModel', () async {
      // ARRANGE
      await testee.push(trainId1);

      // ACT
      await testee.push(trainId2);

      // EXPECT
      final model = testee.modelValue!;
      expect(model.trainIdentification, trainId2);
      expect(model.currentIndex, 1);
      expect(model.navigationStackLength, 2);
    });

    test('push_whenSameJourneyAddedTwice_thenDoesNotChangeModelOrLength', () async {
      // ARRANGE
      await testee.push(trainId1);
      final model1 = testee.modelValue;

      // ACT
      await testee.push(trainId1);

      // EXPECT
      final model2 = testee.modelValue;
      expect(model2, model1);
      expect(model2!.trainIdentification, trainId1);
      expect(model2.currentIndex, 0);
      expect(model2.navigationStackLength, 1);
    });

    test('push_whenNewJourneyAddedAfterInit_thenCallsConnectInRepoButNotDisconnect', () async {
      // ACT
      await testee.push(trainId1);

      // EXPECT
      verify(mockSferaRepo.connect(any)).called(1);
      verifyNever(mockSferaRepo.disconnect());
    });

    test('push_whenSameJourneyAdded_thenDoesNotCallConnectInRepoTwice', () async {
      // ARRANGE
      await testee.push(trainId1);
      reset(mockSferaRepo);

      // ACT
      await testee.push(trainId1);

      // EXPECT
      verifyNever(mockSferaRepo.connect(any));
      verifyNever(mockSferaRepo.disconnect());
    });

    test('push_whenNewJourneyAdded_thenCallsDisconnectAndConnectInRepo', () async {
      // ARRANGE
      await testee.push(trainId1);
      reset(mockSferaRepo);

      // ACT
      await testee.push(trainId2);

      // EXPECT
      verify(mockSferaRepo.connect(trainId2)).called(1);
      verify(mockSferaRepo.disconnect()).called(1);
    });

    test('next_whenCalled_thenMovesToNextJourney', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);
      await testee.push(trainId2); // set current to trainId2

      // ACT
      await testee.next();

      // EXPECT
      final model = testee.modelValue!;
      expect(model.trainIdentification, trainId3);
      expect(model.currentIndex, 2);
      expect(model.navigationStackLength, 3);
    });

    test('next_whenCalled_thenDisconnectsAndConnectsToNewTrainId', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);
      await testee.push(trainId2); // set current to trainId2
      reset(mockSferaRepo);

      // ACT
      await testee.next();

      // EXPECT
      verify(mockSferaRepo.connect(any)).called(1);
      verify(mockSferaRepo.disconnect()).called(1);
    });

    test('next_whenAtEnd_thenDoesNotChangeModel', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);
      await testee.push(trainId3); // set current to last
      final modelBefore = testee.modelValue;

      // ACT
      await testee.next();

      // EXPECT
      final modelAfter = testee.modelValue;
      expect(modelAfter, modelBefore);
      expect(modelAfter!.trainIdentification, trainId3);
      expect(modelAfter.currentIndex, 2);
      expect(modelAfter.navigationStackLength, 3);
    });

    test('previous_whenCalled_thenMovesToPreviousJourney', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);
      await testee.push(trainId2); // set current to trainId2

      // ACT
      await testee.previous();

      // EXPECT
      final model = testee.modelValue!;
      expect(model.trainIdentification, trainId1);
      expect(model.currentIndex, 0);
      expect(model.navigationStackLength, 3);
    });

    test('previous_whenCalled_thenDisconnectsAndConnectsToNewTrainId', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);
      await testee.push(trainId2); // set current to trainId2
      reset(mockSferaRepo);

      // ACT
      await testee.previous();

      // EXPECT
      verify(mockSferaRepo.connect(any)).called(1);
      verify(mockSferaRepo.disconnect()).called(1);
    });

    test('previous_whenAtStart_thenDoesNotChangeModel', () async {
      // ARRANGE
      await testee.push(trainId1);
      final modelBefore = testee.modelValue;

      // ACT
      await testee.previous();

      // EXPECT
      final modelAfter = testee.modelValue;
      expect(modelAfter, modelBefore);
      expect(modelAfter!.trainIdentification, trainId1);
      expect(modelAfter.currentIndex, 0);
      expect(modelAfter.navigationStackLength, 1);
    });

    test('dispose_whenCalled_thenClearsJourneysAndClosesStream', () async {
      // ARRANGE
      await testee.push(trainId1);

      // ACT
      testee.dispose();

      // EXPECT
      expect(() => testee.modelValue, returnsNormally);
      verify(mockSferaRepo.disconnect()).called(1);
    });
    test('model_stream_whenSferaRemoteRepoDisconnectsWithError_thenEmitsNullOnce', () async {
      // ARRANGE
      await testee.push(trainId1);
      await processStreams();
      emitRegister.clear();
      when(mockSferaRepo.lastError).thenReturn(SferaError.requestTimeout);

      // ACT
      mockStream.add(SferaRemoteRepositoryState.disconnected);
      await processStreams();

      // EXCPECT
      expect(emitRegister.length, 1);
      expect(emitRegister.first, isNull);
    });

    test('model_stream_whenPushCalledMultipleTimesWithSameTrainId_thenEmitsOnce', () async {
      // ACT
      await testee.push(trainId1);
      await testee.push(trainId1);
      await testee.push(trainId1);

      await processStreams();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 1);
    });

    test('model_stream_whenPushDifferentTrainIds_thenEmitsForEach', () async {
      // ACT
      await testee.push(trainId1);
      await testee.push(trainId2);
      await testee.push(trainId3);

      await processStreams();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 3);
    });

    test('model_stream_whenNextOrPreviousCalledAtBounds_thenDoesNotEmit', () async {
      // ARRANGE
      await testee.push(trainId1);
      await processStreams();
      emitRegister.clear();

      // ACT
      await testee.previous(); // at start, should not emit
      await testee.next(); // at end, should not emit

      await processStreams();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 0);
    });

    test('model_stream_whenNextAndPreviousCalledWithinBounds_thenEmits', () async {
      // ARRANGE
      await testee.push(trainId1);
      await testee.push(trainId2);
      await processStreams();
      emitRegister.clear();

      // ACT
      await testee.previous(); // should emit (move to trainId1)
      await testee.next(); // should emit (move to trainId2)

      await processStreams();

      // EXPECT
      expect(emitRegister.where((e) => e != null).length, 2);
    });
  });
}
