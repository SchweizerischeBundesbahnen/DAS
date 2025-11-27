import 'package:sfera/component.dart';

abstract class BaseFootNote extends JourneyAnnotation {
  const BaseFootNote({
    required super.order,
    required this.footNote,
    required super.dataType,
  });

  final FootNote footNote;

  String get identifier => footNote.identifier ?? hashCode.toString();

  @override
  String toString() {
    return 'BaseFootNote{order: $order, footNote: $footNote}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseFootNote && runtimeType == other.runtimeType && footNote == other.footNote && order == other.order;

  @override
  int get hashCode => dataType.hashCode ^ footNote.hashCode ^ order.hashCode;
}
