import 'package:sfera/src/model/otn_id.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

class TrainIdentification extends SferaXmlElement {
  static const String elementType = 'TrainIdentification';

  TrainIdentification({super.type = elementType, super.attributes, super.children, super.value});

  factory TrainIdentification.create({OtnId? otnId}) {
    final trainIdentification = TrainIdentification();

    if (otnId != null) {
      trainIdentification.children.add(otnId);
    }

    return trainIdentification;
  }

  OtnId get otnId => children.whereType<OtnId>().first;

  @override
  bool validate() {
    return validateHasChildOfType<OtnId>() && super.validate();
  }
}
