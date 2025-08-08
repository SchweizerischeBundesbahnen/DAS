import 'package:sfera/src/model/journey/base_foot_note.dart';
import 'package:sfera/src/model/journey/datatype.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class LineFootNote extends BaseFootNote {
  const LineFootNote({
    required super.order,
    required super.footNote,
    required this.locationName,
  }) : super(type: Datatype.lineFootNote);

  final String locationName;

  @override
  OrderPriority get orderPriority => OrderPriority.lineFootNotes;
}
