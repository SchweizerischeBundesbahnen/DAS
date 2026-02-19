import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../test_util.dart';

void main() {
  late NotificationPriorityQueueViewModel testee;
  final MockCallback mockCallback = MockCallback();
  final MockCallback mockCallback2 = MockCallback();

  setUp(() {
    testee = NotificationPriorityQueueViewModel();
  });

  tearDown(() {
    mockCallback.reset();
    mockCallback2.reset();
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

    // ACT
    testee.insert(type: .advisedSpeed);

    // EXPECT
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

    // ACT
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .advisedSpeed);

    // EXPECT
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('callback_whenSingleItemInsertedWithCallback_thenCallbackIsCalled', () {
    // ACT
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);

    // EXPECT
    expect(mockCallback.callCounter, equals(1));
  });

  test('callback_whenSingleItemWithCallbackInsertedTwice_thenCallbackIsCalledTwice', () {
    // ACT
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);

    // EXPECT
    expect(mockCallback.callCounter, equals(2));
  });

  test('callback_whenSingleItemInsertedWithAndWithoutCallback_thenCallbackIsCalledOnce', () {
    // ACT
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .advisedSpeed);

    // EXPECT
    expect(mockCallback.callCounter, equals(1));
  });

  test('modelValue_whenSingleStreamAdded_thenEmitsCorrectlyDependingOnStream', () async {
    // ARRANGE
    expectLater(
      testee.model,
      emitsInOrder([
        List.empty(),
        <NotificationType>[.advisedSpeed],
      ]),
    );
    final controller = BehaviorSubject<bool>.seeded(false);
    testee.addStream(type: .advisedSpeed, stream: controller.stream);

    // ACT
    controller.add(true);
    await processStreams();

    // EXPECT
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed]));
  });

  test('modelValue_whenTwoStreamsAdded_thenEmitsCorrectlyDependingOnStreams', () async {
    // ARRANGE
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

    // ACT
    controller.add(true);
    controller2.add(true);

    controller.add(false);
    await processStreams();

    // EXPECT
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

    // ACT
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);

    // EXPECT
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed, .departureDispatch]));
  });

  test('callback_whenTwoItemsInsertedWithCallbacks_thenCallbacksAreAllCalled', () {
    // ACT
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .departureDispatch, callback: mockCallback2.call);

    // EXPECT
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

    // ACT
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);
    testee.insert(type: .illegalSegmentNoReplacement);

    // EXPECT
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

    // ARRANGE
    testee.insert(type: .advisedSpeed);

    // ACT
    testee.remove(type: .advisedSpeed);

    // EXPECT
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

    // ARRANGE
    testee.insert(type: .advisedSpeed);

    // ACT
    testee.remove(type: .advisedSpeed);
    testee.remove(type: .advisedSpeed);

    // EXPECT
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

    // ARRANGE
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);

    // ACT
    testee.remove(type: .departureDispatch);

    // EXPECT
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

    // ARRANGE
    testee.insert(type: .advisedSpeed);
    testee.insert(type: .departureDispatch);
    testee.insert(type: .illegalSegmentNoReplacement);

    // ACT
    testee.remove(type: .illegalSegmentNoReplacement);

    // EXPECT
    expect(testee.modelValue, equals(<NotificationType>[.advisedSpeed, .departureDispatch]));
  });

  test('callback_whenThreeItemsInsertedAndRemovedInSpecialOrder_thenCallbacksAreAllCalledCorrectly', () {
    // ARRANGE
    testee.insert(type: .advisedSpeed, callback: mockCallback.call);
    testee.insert(type: .illegalSegmentNoReplacement);
    testee.insert(type: .departureDispatch, callback: mockCallback2.call);

    // should not call since low priority
    expect(mockCallback2.callCounter, equals(0));

    // ACT
    testee.remove(type: .illegalSegmentNoReplacement);

    // EXPECT
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
