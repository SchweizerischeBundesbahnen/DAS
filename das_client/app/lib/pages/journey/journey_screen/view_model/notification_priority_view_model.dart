import 'dart:async';

import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _logger = Logger('NotificationPriorityQueueViewModel');

/// Prioritizes and caps the notifications shown in [NotificationSpace].
///
/// Allows custom callbacks to be called once the notification is shown, e.g. for playing a sound.
///
/// Notifications can be added in two ways:
///
/// 1. via [insert] or removed via [remove]
/// 2. via a Stream<bool> that implicitly handles [insert] and [remove] operations
class NotificationPriorityQueueViewModel extends JourneyAwareViewModel {
  final Map<NotificationType, VoidCallback?> _notificationTypeToCallback = {
    for (final val in NotificationType.values) val: null,
  };

  final _activeNotifications = <NotificationType>{};

  final Map<NotificationType, StreamSubscription<bool>?> _subscriptions = {};

  final BehaviorSubject<List<NotificationType>> _rxNotifications = BehaviorSubject.seeded(List.empty());

  Stream<List<NotificationType>> get model => _rxNotifications.stream.distinct();

  List<NotificationType> get modelValue => _rxNotifications.value;

  void addStream({
    required NotificationType type,
    required Stream<bool> stream,
    VoidCallback? callback,
  }) {
    _subscriptions[type] = stream.listen((insertNotification) {
      _logger.fine('Received from stream $type: $insertNotification');
      if (insertNotification) {
        insert(type: type, callback: callback);
      } else {
        remove(type: type);
      }
    });
  }

  void removeStream({required NotificationType type}) {
    remove(type: type);
    _subscriptions[type]?.cancel();
    _subscriptions[type] = null;
  }

  void insert({required NotificationType type, VoidCallback? callback}) {
    _activeNotifications.add(type);
    _notificationTypeToCallback[type] = callback;
    _emitMaximumTwoPrioritizedNotifications();
    _callCallbacks();
  }

  void remove({required NotificationType type}) {
    _activeNotifications.remove(type);
    _emitMaximumTwoPrioritizedNotifications();
    _callCallbacks();
  }

  @override
  void dispose() {
    _activeNotifications.clear();
    _notificationTypeToCallback.clear();
    _cancelSubscriptions();
    _rxNotifications.close();
    super.dispose();
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _activeNotifications.clear();
    _notificationTypeToCallback.clear();
    _rxNotifications.add(List.empty());
    _cancelSubscriptions();
  }

  void _emitMaximumTwoPrioritizedNotifications() {
    final toEmit = _activeNotifications.sorted((a, b) => a.index.compareTo(b.index)).take(2).toList(growable: false);

    if (ListEquality().equals(toEmit, modelValue)) return;
    
    if (_rxNotifications.isClosed) {
      _logger.warning('Trying to emit while stream is already closed');
      return;
    } else {
      _logger.fine('Emitting active notifications: $toEmit');
      _rxNotifications.add(toEmit);
    }
  }

  void _callCallbacks() {
    for (final type in modelValue) {
      final callback = _notificationTypeToCallback[type];
      // only call callback for the first time the notification is shown
      _notificationTypeToCallback[type] = null;
      callback?.call();
    }
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions.values) {
      sub?.cancel();
    }
    _subscriptions.clear();
  }
}
