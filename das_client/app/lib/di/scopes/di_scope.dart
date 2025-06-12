import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final _log = Logger('DIScope');

abstract class DIScope {
  String get scopeName;

  final getIt = GetIt.I;

  Future<void> push();

  Future<bool> pop() async {
    _log.fine('Popping scope $scopeName');
    return GetIt.I.popScopesTill(scopeName);
  }

  Future<bool> popAbove() async {
    _log.fine('Popping scope above $scopeName');
    return GetIt.I.popScopesTill(scopeName, inclusive: false);
  }
}
