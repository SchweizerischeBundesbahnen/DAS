import 'package:das_client/util/annotations/non_production.dart';

@nonProduction
class UxTesting {
  const UxTesting({required this.name, required this.value});

  final String name;
  final String value;

  bool get isWarn => name == 'warn';
}
