import 'package:core_data/component.dart';

class const RuIndication({
  required final String title,
  required final String text,
  required super.order,
}) extends JourneyAnnotation {
  this : super(dataType: .ruIndication);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuIndication &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          text == other.text &&
          order == other.order;

  @override
  int get hashCode => Object.hash(title, text, order);

  @override
  String toString() {
    return 'RuIndication{order: $order, title: $title, text: $text}';
  }
}
