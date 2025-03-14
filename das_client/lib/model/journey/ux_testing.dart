import 'package:das_client/util/annotations/non_production.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
@nonProduction
class UxTesting {
  const UxTesting({required this.name, required this.value});

  final String name;
  final String value;

  bool get isWarn => name == 'warn';

  bool get isKoa => name == 'koa';
}
