import 'package:das_client/sfera/src/model/delay.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class TrainLocationInformation extends SferaXmlElement {
  static const String elementType = 'TrainLocationInformation';


  TrainLocationInformation({super.type = elementType, super.attributes, super.children, super.value});

  Delay get delay => children.whereType<Delay>().first;

  @override
  bool validate() {
    return validateHasChildOfType<Delay>() && super.validate();
  }
}
