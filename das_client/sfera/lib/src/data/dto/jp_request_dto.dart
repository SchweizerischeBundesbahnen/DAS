import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';

class JpRequestDto extends SferaXmlElementDto {
  static const String elementType = 'JP_Request';

  JpRequestDto({super.type = elementType, super.attributes, super.children, super.value});

  factory JpRequestDto.create(TrainIdentificationDto trainIdentification) {
    final request = JpRequestDto();
    request.children.add(trainIdentification);
    return request;
  }
}
