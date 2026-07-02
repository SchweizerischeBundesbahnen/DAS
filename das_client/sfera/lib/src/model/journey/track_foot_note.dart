import 'package:core_data/component.dart';
import 'package:sfera/src/model/journey/base_foot_note.dart';

class TrackFootNote extends BaseFootNote {
  const TrackFootNote({
    required super.order,
    required super.footNote,
  }) : super(dataType: .trackFootNote);

  @override
  OrderPriority get orderPriority => .trackFootNote;

  @override
  String toString() {
    return 'TrackFootNote{order: $order, footNote: $footNote}';
  }
}
