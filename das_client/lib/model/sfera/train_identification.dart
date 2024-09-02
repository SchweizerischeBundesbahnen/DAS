import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class TrainIdentification extends SferaXmlElement {
  static const String elementType = "TrainIdentification";

  TrainIdentification({super.type = elementType, super.attributes, super.children, super.value});

  factory TrainIdentification.create({OtnId? otnId}) {
    final trainIdentification = TrainIdentification();

    if (otnId != null) {
      trainIdentification.children.add(otnId);
    }

    return trainIdentification;
  }

  OtnId? get otnId => children.whereType<OtnId>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<OtnId>() && super.validate();
  }
}
