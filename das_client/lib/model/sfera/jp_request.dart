import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/train_identification.dart';

class JpRequest extends SferaXmlElement {
  static const String elementType = 'JP_Request';

  JpRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory JpRequest.create(TrainIdentification trainIdentification) {
    final request = JpRequest();
    request.children.add(trainIdentification);
    return request;
  }
}
