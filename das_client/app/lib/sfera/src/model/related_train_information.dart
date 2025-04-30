import 'package:app/sfera/src/model/sfera_xml_element.dart';

import 'package:app/sfera/src/model/own_train.dart';

class RelatedTrainInformation extends SferaXmlElement {
  static const String elementType = 'RelatedTrainInformation';

  RelatedTrainInformation({super.type = elementType, super.attributes, super.children, super.value});

  OwnTrain get ownTrain => children.whereType<OwnTrain>().first;

  @override
  bool validate() {
    return validateHasChildOfType<OwnTrain>() && super.validate();
  }
}
