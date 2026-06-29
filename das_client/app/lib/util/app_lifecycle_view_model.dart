import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('AppLifecycleViewModel');

class AppLifecycleViewModel {
  final _rxState = BehaviorSubject<AppLifecycleState>();
  final _rxOnResumed = PublishSubject<void>();
  var _wasBackgrounded = false;

  /// Emits an event when the [AppLifecycleState] of the app changes.
  Stream<AppLifecycleState> get state => _rxState.distinct();

  /// Emits an event when the app returns to the foreground from background.
  Stream<void> get onResumed => _rxOnResumed.stream;

  void updateState(AppLifecycleState state) {
    _log.fine('Lifecycle state of app changed to $state');

    if (state == .paused || state == .hidden || state == .detached) {
      _wasBackgrounded = true;
    }

    final previousState = _rxState.valueOrNull;
    if (state == .resumed && previousState != null && _wasBackgrounded) {
      _rxOnResumed.add(null);
      _wasBackgrounded = false;
    }

    _rxState.add(state);
  }

  void dispose() {
    _rxState.close();
    _rxOnResumed.close();
  }
}
