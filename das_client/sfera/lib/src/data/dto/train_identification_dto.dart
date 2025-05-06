import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TrainIdentificationDto extends SferaXmlElementDto {
  static const String elementType = 'TrainIdentification';

  TrainIdentificationDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TrainIdentificationDto.create({OtnIdDto? otnId}) {
    final trainIdentification = TrainIdentificationDto();

    if (otnId != null) {
      trainIdentification.children.add(otnId);
    }

    return trainIdentification;
  }

  OtnIdDto get otnId => children.whereType<OtnIdDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<OtnIdDto>() && super.validate();
  }
}
