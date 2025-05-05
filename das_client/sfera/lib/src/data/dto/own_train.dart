import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/dto/train_location_information.dart';

class OwnTrain extends SferaXmlElement {
  static const String elementType = 'OwnTrain';

  OwnTrain({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentificationDto get trainIdentification => children.whereType<TrainIdentificationDto>().first;

  TrainLocationInformation get trainLocationInformation => children.whereType<TrainLocationInformation>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentificationDto>() &&
        validateHasChildOfType<TrainLocationInformation>() &&
        super.validate();
  }
}
