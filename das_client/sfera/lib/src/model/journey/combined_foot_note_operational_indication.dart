import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

/// This class is used to combine foot notes and operational indication on the same service point.
/// This is needed to simplify the sticky behavior. Otherwise a third StickyLevel would be needed.
/// This is seen as a workaround and a more robust/extendable solution is needed.
class CombinedFootNoteOperationalIndication extends JourneyAnnotation {
  CombinedFootNoteOperationalIndication({
    required this.footNote,
    required this.operationalIndication,
  }) : super(type: Datatype.combinedFootNoteOperationalIndication, order: operationalIndication.order);

  final BaseFootNote footNote;
  final UncodedOperationalIndication operationalIndication;

  @override
  OrderPriority get orderPriority => OrderPriority.uncodedOperationalIndication;

  @override
  String toString() {
    return 'CombinedFootNoteOperationalIndication{order: $order, footNote: $footNote, operationalIndication: $operationalIndication}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombinedFootNoteOperationalIndication &&
          footNote == other.footNote &&
          operationalIndication == other.operationalIndication &&
          order == other.order);

  @override
  int get hashCode => Object.hash(type, order, footNote, operationalIndication);
}
