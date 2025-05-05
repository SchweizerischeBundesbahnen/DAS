import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';

class JpRequest extends SferaXmlElement {
  static const String elementType = 'JP_Request';

  JpRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory JpRequest.create(TrainIdentificationDto trainIdentification) {
    final request = JpRequest();
    request.children.add(trainIdentification);
    return request;
  }
}
