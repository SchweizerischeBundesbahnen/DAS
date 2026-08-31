import 'package:sfera/src/data/dto/own_train_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class RelatedTrainInformationDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'RelatedTrainInformation';

  OwnTrainDto get ownTrain => children.whereType<OwnTrainDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<OwnTrainDto>() && super.validate();
  }
}
