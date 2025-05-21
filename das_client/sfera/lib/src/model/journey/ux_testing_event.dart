import 'package:meta/meta.dart';

@sealed
@immutable
class UxTestingEvent {
  const UxTestingEvent({required this.name, required this.value});

  final String name;
  final String value;

  bool get isWarn => name == 'warn';

  bool get isKoa => name == 'koa';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UxTestingEvent && runtimeType == other.runtimeType && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
