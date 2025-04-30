import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/datatype.dart';

class SpeedChange extends BaseData {
  const SpeedChange({required super.order, required super.kilometre, required super.speedData, this.text})
      : super(type: Datatype.speedChange);

  final String? text;
}
