import 'dart:async';
import 'dart:ui';

import 'package:app/util/app_lifecycle_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_util.dart';

void main() {
  late AppLifecycleViewModel testee;
  late List<AppLifecycleState> stateEmittedValues;
  late List<void> onResumedEmittedValues;
  late StreamSubscription<AppLifecycleState> stateSubscription;
  late StreamSubscription<void> onResumedSubscription;

  setUp(() {
    testee = AppLifecycleViewModel();
    stateEmittedValues = <AppLifecycleState>[];
    onResumedEmittedValues = <void>[];
    stateSubscription = testee.state.listen(stateEmittedValues.add);
    onResumedSubscription = testee.onResumed.listen(onResumedEmittedValues.add);
  });

  tearDown(() async {
    await stateSubscription.cancel();
    await onResumedSubscription.cancel();
    testee.dispose();
  });

  test('state_whenUpdated_thenEmitsDistinctValues', () async {
    // ACT
    testee.updateState(.resumed);
    testee.updateState(.resumed);
    testee.updateState(.inactive);
    await processStreams();

    // VERIFY
    expect(stateEmittedValues, equals([AppLifecycleState.resumed, AppLifecycleState.inactive]));
  });

  test('onResumed_whenResumedWithoutPreviousState_thenEmitsNothing', () async {
    // ACT
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, isEmpty);
  });

  test('onResumed_whenResumedAfterPaused_thenEmitsEvent', () async {
    testee.updateState(.paused);
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, hasLength(1));
  });

  test('onResumed_whenResumedAfterHidden_thenEmitsEvent', () async {
    // ACT
    testee.updateState(.hidden);
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, hasLength(1));
  });

  test('onResumed_whenResumedAfterDetached_thenEmitsEvent', () async {
    // ACT
    testee.updateState(.detached);
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, hasLength(1));
  });

  test('onResumed_whenResumedTwiceAfterSingleBackground_thenEmitsOnce', () async {
    // ACT
    testee.updateState(.paused);
    testee.updateState(.resumed);
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, hasLength(1));
  });

  test('onResumed_whenBackgroundedTwice_thenEmitsTwice', () async {
    // ACT
    testee.updateState(.paused);
    testee.updateState(.resumed);
    testee.updateState(.hidden);
    testee.updateState(.resumed);
    await processStreams();

    // VERIFY
    expect(onResumedEmittedValues, hasLength(2));
  });
}
