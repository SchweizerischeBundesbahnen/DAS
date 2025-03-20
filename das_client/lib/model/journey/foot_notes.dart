import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/foot_note.dart';

class FootNotes extends BaseData {
  FootNotes({
    required super.order,
    required this.footNotes,
  }) : super(kilometre: [], type: Datatype.footNotes);

  final List<FootNote> footNotes;
}
