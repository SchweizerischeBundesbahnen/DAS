import 'package:sfera/src/model/journey/base_foot_note.dart';
import 'package:sfera/src/model/journey/datatype.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class TrackFootNote extends BaseFootNote {
  const TrackFootNote({
    required super.order,
    required super.footNote,
  }) : super(type: Datatype.trackFootNote);

  @override
  OrderPriority get orderPriority => OrderPriority.trackFootNote;

  @override
  String toString() {
    return 'TrackFootNote{order: $order, footNote: $footNote}';
  }
}
