import 'package:meta/meta.dart';

@sealed
@immutable
class UxTesting {
  const UxTesting({required this.name, required this.value});

  final String name;
  final String value;

  bool get isWarn => name == 'warn';

  bool get isKoa => name == 'koa';
}
