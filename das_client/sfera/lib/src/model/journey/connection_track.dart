import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class ConnectionTrack extends BaseData {
  const ConnectionTrack({required super.order, required super.kilometre, this.text, super.speedData})
    : super(type: Datatype.connectionTrack);

  final String? text;

  @override
  String toString() {
    return 'ConnectionTrack(text: $text)';
  }
}
