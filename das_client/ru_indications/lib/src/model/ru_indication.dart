import 'package:core_data/component.dart';

class RuIndication extends JourneyAnnotation {
  const RuIndication({
    required this.title,
    required this.text,
    required super.order,
  }) : super(dataType: .lineFootNote); // TODO: add ruIndication datatype

  final String title;
  final String text;

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
}
