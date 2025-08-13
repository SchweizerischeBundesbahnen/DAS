import 'package:sfera/component.dart';

abstract class BaseFootNote extends JourneyAnnotation {
  const BaseFootNote({
    required super.order,
    required this.footNote,
    required super.type,
  });

  final FootNote footNote;

  String get identifier => footNote.identifier ?? hashCode.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseFootNote && runtimeType == other.runtimeType && footNote == other.footNote && order == other.order;

  @override
  int get hashCode => footNote.hashCode ^ order.hashCode;
}
