import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/speed_data.dart';

class ConnectionTrack extends BaseData {
  ConnectionTrack({required super.order, required super.kilometre, this.text, this.speedData})
      : super(type: Datatype.connectionTrack);

  final String? text;
  final SpeedData? speedData;
}
