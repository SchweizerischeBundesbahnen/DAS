import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/model/train_identification.dart';
import 'package:app/sfera/src/model/train_location_information.dart';

class OwnTrain extends SferaXmlElement {
  static const String elementType = 'OwnTrain';

  OwnTrain({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentification get trainIdentification => children.whereType<TrainIdentification>().first;

  TrainLocationInformation get trainLocationInformation => children.whereType<TrainLocationInformation>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentification>() &&
        validateHasChildOfType<TrainLocationInformation>() &&
        super.validate();
  }
}
