import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/di_scope.dart';
import 'package:get_it/get_it.dart';

class ScopeHandlerImpl implements ScopeHandler {
  @override
  String? getCurrentScopeName() => GetIt.I.currentScopeName;

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
}
