import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:get_it/get_it.dart';

class ScopeHandlerImpl implements ScopeHandler {
  @override
  bool isTop<T extends DIScope>() {
    final currentScopeName = GetIt.I.currentScopeName;
    if (currentScopeName == null) return false;

    final tName = _getScope<T>().scopeName;
    return currentScopeName == tName;
  }

  @override
  Future<bool> pop<T extends DIScope>() {
    return _getScope<T>().pop();
  }

  @override
  Future<bool> popAbove<T extends DIScope>() {
    return _getScope<T>().popAbove();
  }

  @override
  Future<void> push<T extends DIScope>() {
    return _getScope<T>().push();
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
}
