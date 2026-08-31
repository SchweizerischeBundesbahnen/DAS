import 'package:core_data/component.dart';
import 'package:sfera/src/model/journey/base_foot_note.dart';

class const LineFootNote({
  required super.order,
  required super.footNote,
  required final String locationName,
}) extends BaseFootNote {
  this : super(dataType: .lineFootNote);

  @override
  OrderPriority get orderPriority => .lineFootNotes;

  @override
  String toString() {
    return 'LineFootNote{order: $order, footNote: $footNote, locationName: $locationName}';
  }
}
