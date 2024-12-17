import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class SpeedChange extends BaseData {
  SpeedChange({required super.order, required super.kilometre, required super.speedData, this.text})
      : super(type: Datatype.speedChange);

  final String? text;
}