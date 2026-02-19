import 'dart:async';

import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _logger = Logger('NotificationPriorityQueueViewModel');

/// Prioritizes and caps the notifications shown in [NotificationSpace].
///
/// Allows custom callbacks to be called once the notification is shown, e.g. for playing a sound.
///
/// Notifications have to be added to the queue via [insert] or removed via [remove].
class NotificationPriorityQueueViewModel {
  final Map<NotificationType, VoidCallback?> _notificationTypeToCallback = {
    for (final val in NotificationType.values) val: null,
  };

  final _activeNotifications = <NotificationType>{};

  final BehaviorSubject<List<NotificationType>> _rxNotifications = BehaviorSubject.seeded(List.empty());

  Stream<List<NotificationType>> get model => _rxNotifications.stream.distinct();

  List<NotificationType> get modelValue => _rxNotifications.value;

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

  void dispose() {
    _activeNotifications.clear();
    _notificationTypeToCallback.clear();
    _rxNotifications.close();
  }

  void _emitMaximumTwoPrioritizedNotifications() {
    final toEmit = _activeNotifications.sorted((a, b) => a.index.compareTo(b.index)).take(2).toList(growable: false);
    _logger.fine('Active Notifications: $_activeNotifications)');
    _logger.fine('Emitting: $toEmit');
    _rxNotifications.add(toEmit);
  }

  void _callCallbacks() {
    for (final type in modelValue) {
      final callback = _notificationTypeToCallback[type];
      // only call callback for the first time the notification is shown
      _notificationTypeToCallback[type] = null;
      callback?.call();
    }
  }
}
