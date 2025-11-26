import 'package:sfera/src/model/journey/base_foot_note.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class OpFootNote extends BaseFootNote {
  const OpFootNote({
    required super.order,
    required super.footNote,
  }) : super(dataType: .opFootNote);

  @override
  OrderPriority get orderPriority => .opFootNote;

  @override
  String toString() {
    return 'OpFootNote{order: $order, footNote: $footNote}';
  }
}
