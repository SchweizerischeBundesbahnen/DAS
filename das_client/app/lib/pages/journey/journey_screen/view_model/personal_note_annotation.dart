import 'package:core_data/component.dart';

class const PersonalNoteAnnotation({
  required final String text,
  required super.order,
}) extends JourneyAnnotation {
  this : super(dataType: .personalNote);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalNoteAnnotation && runtimeType == other.runtimeType && text == other.text && order == other.order;

  @override
  int get hashCode => Object.hash(text, order);

  @override
  String toString() {
    return 'PersonalNoteAnnotation{order: $order, text: $text}';
  }
}
