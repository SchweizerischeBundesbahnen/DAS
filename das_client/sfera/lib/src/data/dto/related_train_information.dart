import 'package:sfera/src/data/dto/sfera_xml_element.dart';

import 'package:sfera/src/data/dto/own_train.dart';

class RelatedTrainInformation extends SferaXmlElement {
  static const String elementType = 'RelatedTrainInformation';

  RelatedTrainInformation({super.type = elementType, super.attributes, super.children, super.value});

  OwnTrain get ownTrain => children.whereType<OwnTrain>().first;

  @override
  bool validate() {
    return validateHasChildOfType<OwnTrain>() && super.validate();
  }
}
