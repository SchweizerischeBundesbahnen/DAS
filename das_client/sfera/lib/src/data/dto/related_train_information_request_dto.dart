import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';

class RelatedTrainInformationRequestDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'RelatedTrainInformationRequest';

  factory create(TrainIdentificationDto trainIdentification) {
    final request = RelatedTrainInformationRequestDto();
    request.children.add(trainIdentification);
    return request;
  }
}
