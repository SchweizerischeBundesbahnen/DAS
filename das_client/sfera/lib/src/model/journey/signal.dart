import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

class const Signal({
  required super.order,
  required super.kilometre,
  final String? visualIdentifier,
  final List<SignalFunction> functions = const [],
  super.lastModificationDate,
  super.lastModificationType,
}) extends JourneyPoint {
  this : super(dataType: .signal);

  @override
  OrderPriority get orderPriority => .signal;

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is Signal &&
          other.dataType == dataType &&
          other.order == order &&
          ListEquality().equals(other.kilometre, kilometre) &&
          other.visualIdentifier == visualIdentifier &&
          ListEquality().equals(other.functions, functions));

  @override
  int get hashCode =>
      Object.hash(dataType, order, ListEquality().hash(kilometre), visualIdentifier, ListEquality().hash(functions));

  @override
  String toString() {
    return 'Signal{order: $order, kilometre: $kilometre, functions: $functions, visualIdentifier: $visualIdentifier}';
  }
}

enum SignalFunction {
  entry,
  exit,
  intermediate,
  block,
  protection,
  laneChange,
  lockingOutSignal, // from NSP
  etcsStopSign, // from NSP
  trackEndSignal, // from NSP
  unknown;

  factory from(String value) => values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => .unknown,
  );
}
