import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class Signal extends JourneyPoint {
  const Signal({
    required super.order,
    required super.kilometre,
    this.visualIdentifier,
    this.functions = const [],
    super.lastModificationDate,
    super.lastModificationType,
  }) : super(dataType: .signal);

  final List<SignalFunction> functions;
  final String? visualIdentifier;

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
  unknown
  ;

  factory SignalFunction.from(String value) {
    return values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => .unknown,
    );
  }
}
