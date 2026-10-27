import 'package:meta/meta.dart';

@sealed
@immutable
class const UxTestingEvent({required final String name, required final String value}) {
  bool get isWarn => name == 'warn';

  bool get isKoa => name == 'koa';

  bool get isConnectivity => name == 'connectivity';

  bool get isFormation => name == 'formation';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UxTestingEvent && runtimeType == other.runtimeType && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'UxTestingEvent{name: $name, value: $value}';
  }
}
