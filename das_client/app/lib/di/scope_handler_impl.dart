import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ScopeHandlerImpl implements ScopeHandler {
  ScopeHandlerImpl();

  final _scopeSubject = PublishSubject<void>();

  @override
  Stream<void> get onScopeChanged => _scopeSubject.stream;

  @override
  bool isTop<T extends DIScope>() {
    final currentScopeName = GetIt.I.currentScopeName;
    if (currentScopeName == null) return false;

    final tName = _getScope<T>().scopeName;
    return currentScopeName == tName;
  }

  @override
  Future<bool> pop<T extends DIScope>() async {
    final result = await _getScope<T>().pop();
    _emitChange();
    return result;
  }

  @override
  Future<bool> popAbove<T extends DIScope>() async {
    final result = await _getScope<T>().popAbove();
    _emitChange();
    return result;
  }

  @override
  Future<void> push<T extends DIScope>() async {
    await _getScope<T>().push();
    _emitChange();
  }

  void _emitChange() {
    if (!_scopeSubject.isClosed) {
      _scopeSubject.add(null);
    }
  }

  @override
  bool isInStack<T extends DIScope>() {
    final scopeName = _getScope<T>().scopeName;
    return GetIt.I.hasScope(scopeName);
  }

  DIScope _getScope<T extends DIScope>() {
    try {
      return DI.get<T>();
    } catch (e) {
      throw UnimplementedError('Scope not implemented for type: $T');
    }
  }

  void dispose() {
    _scopeSubject.close();
  }
}
