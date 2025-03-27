import 'package:das_client/model/journey/base_foot_note.dart';
import 'package:das_client/model/journey/datatype.dart';

class OpFootNote extends BaseFootNote {
  OpFootNote({
    required super.order,
    required super.footNote,
  }) : super(type: Datatype.opFootNote);

  @override
  int get orderPriority => 1;
}
