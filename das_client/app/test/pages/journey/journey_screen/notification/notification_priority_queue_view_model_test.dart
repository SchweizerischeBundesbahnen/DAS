import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../test_util.dart';
import 'notification_priority_queue_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
])
void main() {
  late MockJourneyViewModel mockJourneyViewModel;
  late NotificationPriorityQueueViewModel testee;
  final MockCallback mockCallback = MockCallback();
  final MockCallback mockCallback2 = MockCallback();

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    GetIt.I.registerSingleton<JourneyViewModel>(mockJourneyViewModel);
    testee = NotificationPriorityQueueViewModel();
  });

  tearDown(() {
    mockCallback.reset();
    mockCallback2.reset();
    GetIt.I.reset();
  });

  test('modelValue_whenNoItemInserted_thenIsEmpty', () {
    expectLater(testee.model, emitsInOrder([List.empty()]));

    expect(testee.modelValue, equals(List.empty()));
  });

  test('modelValue_whenSingleItemInserted_thenIsSingleCorrectNotification', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
      ]),
    );

    // WHEN
    testee.insert(type: .advisedSpeed);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('modelValue_whenSingleItemInsertedTwice_thenIsEmittedOnlyOnce', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
      ]),
    );

    // WHEN
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .advisedSpeed);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('callback_whenSingleItemInsertedWithCallback_thenCallbackIsCalled', () {
    // WHEN
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);

    // THEN
    expect(mockCallback.callCounter, equals(1));
  });

  test('callback_whenSingleItemWithCallbackInsertedTwice_thenCallbackIsCalledTwice', () {
    // WHEN
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);

    // THEN
    expect(mockCallback.callCounter, equals(2));
  });

  test('callback_whenSingleItemInsertedWithAndWithoutCallback_thenCallbackIsCalledOnce', () {
    // WHEN
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .advisedSpeed);

    // THEN
    expect(mockCallback.callCounter, equals(1));
  });

  test('modelValue_whenSingleStreamAdded_thenEmitsCorrectlyDependingOnStream', () async {
    // GIVEN
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
      ]),
    );
    final controller = BehaviorSubject<bool>.seeded(false);
    testee.addStream(type: .advisedSpeed, stream: controller.stream);

    // WHEN
    controller.add(true);
    await processStreams();

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('modelValue_whenSingleStreamAddedThenRemoved_thenEmitsCorrectlyDependingOnStream', () async {
    // GIVEN
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        List.empty(),
      ]),
    );
    final controller = BehaviorSubject<bool>.seeded(false);
    testee.addStream(type: .advisedSpeed, stream: controller.stream);

    // GIVEN
    controller.add(true);
    await processStreams();
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));

    // WHEN
    testee.removeStream(type: .advisedSpeed);
    controller.add(true);
    await processStreams();

    // THEN
    expect(testee.modelValue, equals(List.empty()));
  });

  test('modelValue_whenTwoStreamsAdded_thenEmitsCorrectlyDependingOnStreams', () async {
    // GIVEN
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        <NotificationType>[.disturbance, .advisedSpeed],
        <NotificationType>[.disturbance],
      ]),
    );
    final controller = BehaviorSubject<bool>.seeded(false);
    final controller2 = BehaviorSubject<bool>.seeded(false);
    testee.addStream(type: .advisedSpeed, stream: controller.stream);
    testee.addStream(type: .disturbance, stream: controller2.stream);

    // WHEN
    controller.add(true);
    controller2.add(true);

    controller.add(false);
    await processStreams();

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.disturbance]));
  });

  test('modelValue_whenTwoItemsInserted_thenAreTwoNotifications', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        <NotificationType>[.advisedSpeed, .departureDispatch],
      ]),
    );

    // WHEN
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed, .departureDispatch]));
  });

  test('callback_whenTwoItemsInsertedWithCallbacks_thenCallbacksAreAllCalled', () {
    // WHEN
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .departureDispatch, callback: mockCallback2.call);

    // THEN
    expect(mockCallback.callCounter, equals(1));
    expect(mockCallback2.callCounter, equals(1));
  });

  test('modelValue_whenThreeItemsInserted_thenAreTwoTopPriorityNotifications', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        <NotificationType>[.advisedSpeed, .departureDispatch],
        <NotificationType>[.illegalSegmentNoReplacement, .advisedSpeed],
      ]),
    );

    // WHEN
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);
    testee.insert(type: .illegalSegmentNoReplacement);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.illegalSegmentNoReplacement, .advisedSpeed]));
  });

  test('model_whenItemInsertedThenRemoved_thenShouldEmitCorrectly', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        List.empty(),
      ]),
    );

    // GIVEN
    testee.insert(type: .advisedSpeed);

    // WHEN
    testee.remove(type: .advisedSpeed);

    // THEN
    expect(testee.modelValue, equals(List.empty()));
  });

  test('model_whenItemInsertedThenRemovedTwice_thenShouldEmitCorrectly', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        List.empty(),
      ]),
    );

    // GIVEN
    testee.insert(type: .advisedSpeed);

    // WHEN
    testee.remove(type: .advisedSpeed);
    testee.remove(type: .advisedSpeed);

    // THEN
    expect(testee.modelValue, equals(List.empty()));
  });

  test('model_whenTwoInsertedThenOneRemoved_thenShouldEmitCorrectly', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        <NotificationType>[.advisedSpeed, .departureDispatch],
        <NotificationType>[.advisedSpeed],
      ]),
    );

    // GIVEN
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);

    // WHEN
    testee.remove(type: .departureDispatch);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('model_whenThreeInsertedThenOneRemoved_thenShouldEmitCorrectly', () {
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
        <NotificationType>[.advisedSpeed, .departureDispatch],
        <NotificationType>[.illegalSegmentNoReplacement, .advisedSpeed],
        <NotificationType>[.advisedSpeed, .departureDispatch],
      ]),
    );

    // GIVEN
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);
    testee.insert(type: .illegalSegmentNoReplacement);

    // WHEN
    testee.remove(type: .illegalSegmentNoReplacement);

    // THEN
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed, .departureDispatch]));
  });

  test('callback_whenThreeItemsInsertedAndRemovedInSpecialOrder_thenCallbacksAreAllCalledCorrectly', () {
    // GIVEN
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .illegalSegmentNoReplacement);
    testee.insert(type: .departureDispatch, callback: mockCallback2.call);

    // should not call since low priority
    expect(mockCallback2.callCounter, equals(0));

    // WHEN
    testee.remove(type: .illegalSegmentNoReplacement);

    // THEN
    expect(mockCallback.callCounter, equals(1));
    // called after removing highest priority
    expect(mockCallback2.callCounter, equals(1));
  });
}

class MockCallback {
  int _callCounter = 0;

  int get callCounter => _callCounter;

  void call() {
    _callCounter += 1;
  }

  bool called(int expected) => _callCounter == expected;

  void reset() {
    _callCounter = 0;
  }
}
