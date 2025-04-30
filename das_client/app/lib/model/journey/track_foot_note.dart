import 'package:app/model/journey/base_foot_note.dart';
import 'package:app/model/journey/datatype.dart';
import 'package:app/model/journey/order_priority.dart';

class TrackFootNote extends BaseFootNote {
  TrackFootNote({
    required super.order,
    required super.footNote,
  }) : super(type: Datatype.trackFootNote);

  @override
  OrderPriority get orderPriority => OrderPriority.baseData;
}
