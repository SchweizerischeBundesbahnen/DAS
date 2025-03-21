import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/foot_note.dart';

class OpFootNotes extends BaseData {
  OpFootNotes({
    required super.order,
    required this.footNotes,
  }) : super(kilometre: [], type: Datatype.opFootNotes);

  final List<FootNote> footNotes;

  @override
  int get orderPriority => 1;
}
