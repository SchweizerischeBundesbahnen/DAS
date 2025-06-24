import 'package:app/di/di.dart';

/// The ScopeHandler interface defines methods for managing DI scopes in the application.
abstract interface class ScopeHandler {
  /// Checks whether the given scope is within the stack.
  bool isInStack<T extends DIScope>();

  bool isTop<T extends DIScope>();

  /// Pushes a new scope of the given type.
  Future<void> push<T extends DIScope>();

  /// Pop scopes above the given scope type.
  Future<bool> popAbove<T extends DIScope>();

  /// Pop scopes above and including the given scope type.
  Future<bool> pop<T extends DIScope>();
}
