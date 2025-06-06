import 'package:app/di/scopes/di_scope.dart';

abstract interface class ScopeHandler {
  /// Returns the current scope.
  String? getCurrentScopeName();

  /// Pushes a new scope of the given type.
  Future<void> push<T extends DIScope>();

  /// Pop scopes above the given scope type.
  Future<bool> popAbove<T extends DIScope>();

  /// Pop scopes above and including the given scope type.
  Future<bool> pop<T extends DIScope>();
}
