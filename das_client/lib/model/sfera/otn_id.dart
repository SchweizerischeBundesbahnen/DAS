import 'package:das_client/model/sfera/sfera_xml_element.dart';

class OtnId extends SferaXmlElement {
  static const String elementType = "OTN_ID";

  OtnId({super.type = elementType, super.attributes, super.children, super.value});

  String get company => childrenWithType("Company").first.value!;

  String get operationalTrainNumber => childrenWithType("OperationalTrainNumber").first.value!;

  String? get additionalTrainNumber => childrenWithType("AdditionalTrainNumber").firstOrNull?.value;

  String get startDate => childrenWithType("StartDate").first.value!;

  @override
  bool validate() {
    return validateHasChild("Company") &&
        validateHasChild("OperationalTrainNumber") &&
        validateHasChild("StartDate") &&
        super.validate();
  }
}
