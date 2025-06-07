import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

abstract class DIScope {
  String get scopeName => '';

  final getIt = GetIt.I;

  Future<void> push();

  Future<bool> pop() async {
    Fimber.d('Popping scope $scopeName');
    return GetIt.I.popScopesTill(scopeName);
  }

  Future<bool> popAbove() async {
    Fimber.d('Popping scope above $scopeName');
    return GetIt.I.popScopesTill(scopeName, inclusive: false);
  }
}
