import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/dto/train_location_information_dto.dart';

class OwnTrainDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'OwnTrain';

  TrainIdentificationDto get trainIdentification => children.whereType<TrainIdentificationDto>().first;

  TrainLocationInformationDto? get trainLocationInformation =>
      children.whereType<TrainLocationInformationDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentificationDto>() && super.validate();
  }
}
