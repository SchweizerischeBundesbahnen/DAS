import 'package:sfera/src/data/dto/otn_id.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class TrainIdentificationDto extends SferaXmlElement {
  static const String elementType = 'TrainIdentification';

  TrainIdentificationDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TrainIdentificationDto.create({OtnId? otnId}) {
    final trainIdentification = TrainIdentificationDto();

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
