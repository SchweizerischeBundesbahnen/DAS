import 'package:meta/meta.dart';

@sealed
@immutable
class DisturbanceEvent {
  const DisturbanceEvent({required this.type});

  final DisturbanceEventType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DisturbanceEvent && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'DisturbanceEvent{type: $type}';
  }
}

enum DisturbanceEventType {
  start,
  end,
}
