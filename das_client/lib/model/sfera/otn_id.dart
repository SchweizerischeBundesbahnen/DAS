import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/util/format.dart';

class OtnId extends SferaXmlElement {
  static const String elementType = "OTN_ID";

  OtnId({super.type = elementType, super.attributes, super.children, super.value});

  factory OtnId.create(String company, String operationalTrainNumber, DateTime startDate, {String? additionalTrainNumber}) {
    final otnId = OtnId();
    otnId.children.add(SferaXmlElement(type: "Company", value: company));
    otnId.children.add(SferaXmlElement(type: "OperationalTrainNumber", value: operationalTrainNumber));
    otnId.children.add(SferaXmlElement(type: "StartDate", value: Format.sferaDate(startDate)));
    if (additionalTrainNumber != null) {
      otnId.children.add(SferaXmlElement(type: "AdditionalTrainNumber", value: additionalTrainNumber));
    }

    return otnId;
  }

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
