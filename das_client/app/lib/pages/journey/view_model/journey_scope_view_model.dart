import 'dart:async';

import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('JourneyScopeViewModel');

class JourneyScopeViewModel {
  JourneyScopeViewModel({required ScopeHandler scopeHandler})
    : _scopeHandler = scopeHandler,
      _rxIsJourneyScopeActive = BehaviorSubject<bool>.seeded(scopeHandler.isInStack<JourneyScope>()) {
    _init();
  }

  final ScopeHandler _scopeHandler;
  final BehaviorSubject<bool> _rxIsJourneyScopeActive;
  StreamSubscription<void>? _scopeSubscription;

  Stream<bool> get isJourneyScopeActive => _rxIsJourneyScopeActive.distinct();

  bool get isJourneyScopeActiveValue => _rxIsJourneyScopeActive.value;

  Stream<bool> get model => isJourneyScopeActive;

  bool get modelValue => isJourneyScopeActiveValue;

  void _init() {
    _scopeSubscription = _scopeHandler.onScopeChanged.listen((_) {
      final active = _scopeHandler.isInStack<JourneyScope>();
      _log.fine('JourneyScope active changed: $active');
      _rxIsJourneyScopeActive.add(active);
    });
  }

  void dispose() {
    _log.fine('Disposing JourneyScopeViewModel');
    _scopeSubscription?.cancel();
    _scopeSubscription = null;
    _rxIsJourneyScopeActive.close();
  }
}
