import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class SpeedChange extends BaseData {
  const SpeedChange({required super.order, required super.kilometre, required super.speeds, this.text})
    : super(type: Datatype.speedChange);

  final String? text;
}
