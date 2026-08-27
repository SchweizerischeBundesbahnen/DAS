import 'package:core_data/component.dart';
import 'package:sfera/src/model/journey/base_foot_note.dart';

class const OpFootNote({
  required super.order,
  required super.footNote,
}) extends BaseFootNote {
  this : super(dataType: .opFootNote);

  @override
  OrderPriority get orderPriority => .opFootNote;

  @override
  String toString() {
    return 'OpFootNote{order: $order, footNote: $footNote}';
  }
}
