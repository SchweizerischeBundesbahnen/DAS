import 'package:das_client/model/journey/base_foot_note.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/localized_string.dart';

class LineFootNote extends BaseFootNote {
  LineFootNote({
    required super.order,
    required super.footNote,
    required this.locationName,
  }) : super(type: Datatype.lineFootNote);

  final LocalizedString locationName;

  @override
  int get orderPriority => 2;
}
