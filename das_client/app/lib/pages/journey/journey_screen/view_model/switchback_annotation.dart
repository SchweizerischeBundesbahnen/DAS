import 'package:core_data/component.dart';

class const SwitchbackAnnotation({
  required super.order,
}) extends JourneyAnnotation {
  this : super(dataType: .switchback);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchbackAnnotation && runtimeType == other.runtimeType && order == other.order;

  @override
  int get hashCode => Object.hash(dataType, order);

  @override
  String toString() {
    return 'SwitchbackAnnotation{order: $order}';
  }
}
