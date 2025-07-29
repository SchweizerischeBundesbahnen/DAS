import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

/// This class is used to combine foot notes and operational indication on the same service point.
/// This is needed to simplify the sticky behavior. Otherwise a third StickyLevel would be needed.
/// This is seen as a workaround and a more robust/extendable solution is needed.
class CombinedFootNoteOperationalIndication extends BaseData {
  CombinedFootNoteOperationalIndication({
    required this.footNote,
    required this.operationalIndication,
  }) : super(
         type: Datatype.combinedFootNoteOperationalIndication,
         order: operationalIndication.order,
         kilometre: operationalIndication.kilometre,
       );

  final BaseFootNote footNote;
  final UncodedOperationalIndication operationalIndication;

  @override
  OrderPriority get orderPriority => OrderPriority.uncodedOperationalIndication;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombinedFootNoteOperationalIndication &&
          footNote == other.footNote &&
          operationalIndication == other.operationalIndication &&
          order == other.order &&
          kilometre == other.kilometre);

  @override
  int get hashCode => Object.hash(order, ListEquality().hash(kilometre), footNote, operationalIndication);
}
