import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/dto/train_location_information_dto.dart';

class OwnTrainDto extends SferaXmlElementDto {
  static const String elementType = 'OwnTrain';

  OwnTrainDto({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentificationDto get trainIdentification => children.whereType<TrainIdentificationDto>().first;

  TrainLocationInformationDto get trainLocationInformation => children.whereType<TrainLocationInformationDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentificationDto>() &&
        validateHasChildOfType<TrainLocationInformationDto>() &&
        super.validate();
  }
}
