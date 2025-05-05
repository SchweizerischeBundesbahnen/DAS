import 'package:sfera/src/data/dto/delay.dart';
import 'package:sfera/src/data/dto/position_speed.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class TrainLocationInformation extends SferaXmlElement {
  static const String elementType = 'TrainLocationInformation';

  TrainLocationInformation({super.type = elementType, super.attributes, super.children, super.value});

  Delay get delay => children.whereType<Delay>().first;

  PositionSpeed? get positionSpeed => children.whereType<PositionSpeed>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<Delay>() && super.validate();
  }
}
