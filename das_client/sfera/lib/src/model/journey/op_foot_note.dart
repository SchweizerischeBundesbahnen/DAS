import 'package:sfera/src/model/journey/base_foot_note.dart';
import 'package:sfera/src/model/journey/datatype.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class OpFootNote extends BaseFootNote {
  OpFootNote({
    required super.order,
    required super.footNote,
  }) : super(type: Datatype.opFootNote);

  @override
  OrderPriority get orderPriority => OrderPriority.opFootNote;
}
