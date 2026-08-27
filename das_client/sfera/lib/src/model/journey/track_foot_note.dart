import 'package:core_data/component.dart';
import 'package:sfera/src/model/journey/base_foot_note.dart';

class const TrackFootNote({
  required super.order,
  required super.footNote,
}) extends BaseFootNote {
  this : super(dataType: .trackFootNote);

  @override
  OrderPriority get orderPriority => .trackFootNote;

  @override
  String toString() {
    return 'TrackFootNote{order: $order, footNote: $footNote}';
  }
}
