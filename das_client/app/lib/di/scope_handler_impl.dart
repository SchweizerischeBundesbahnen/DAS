import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:get_it/get_it.dart';

class ScopeHandlerImpl implements ScopeHandler {
  @override
  bool isTop<T extends DIScope>() {
    final currentScopeName = GetIt.I.currentScopeName;
    if (currentScopeName == null) return false;

    final tName = switch (T) {
      const (DASBaseScope) => DASBaseScope().scopeName,
      const (SferaMockScope) => SferaMockScope().scopeName,
      const (TmsScope) => TmsScope().scopeName,
      const (AuthenticatedScope) => AuthenticatedScope().scopeName,
      _ => throw UnimplementedError('isCurrentScope not implemented for scope type: $T'),
    };
    return currentScopeName == tName;
  }

  @override
  Future<bool> pop<T extends DIScope>() {
    return switch (T) {
      const (DASBaseScope) => DASBaseScope().pop(),
      const (SferaMockScope) => SferaMockScope().pop(),
      const (TmsScope) => TmsScope().pop(),
      const (AuthenticatedScope) => AuthenticatedScope().pop(),
      _ => throw UnimplementedError('pop not implemented for scope type: $T'),
    };
  }

  @override
  Future<bool> popAbove<T extends DIScope>() => switch (T) {
    const (DASBaseScope) => DASBaseScope().popAbove(),
    const (SferaMockScope) => SferaMockScope().popAbove(),
    const (TmsScope) => TmsScope().popAbove(),
    const (AuthenticatedScope) => AuthenticatedScope().popAbove(),
    _ => throw UnimplementedError('popAbove not implemented for scope type: $T'),
  };

  @override
  Future<void> push<T extends DIScope>() => switch (T) {
    const (DASBaseScope) => DASBaseScope().push(),
    const (SferaMockScope) => SferaMockScope().push(),
    const (TmsScope) => TmsScope().push(),
    const (AuthenticatedScope) => AuthenticatedScope().push(),
    _ => throw UnimplementedError('push not implemented for scope type: $T'),
  };

  @override
  bool isInStack<T extends DIScope>() {
    final scopeName = switch (T) {
      const (DASBaseScope) => DASBaseScope().scopeName,
      const (SferaMockScope) => SferaMockScope().scopeName,
      const (TmsScope) => TmsScope().scopeName,
      const (AuthenticatedScope) => AuthenticatedScope().scopeName,
      _ => throw UnimplementedError('isInStack not implemented for scope type: $T'),
    };
    return GetIt.I.hasScope(scopeName);
  }
}
