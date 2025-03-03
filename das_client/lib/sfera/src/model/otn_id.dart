import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/util/format.dart';

class OtnId extends SferaXmlElement {
  static const String elementType = 'OTN_ID';

  static const String _companyAttribute = 'teltsi_Company';
  static const String _operationalTrainNumberAttribute = 'teltsi_OperationalTrainNumber';
  static const String _startDateAttribute = 'teltsi_StartDate';
  static const String _additionalTrainNumberAttribute = 'AdditionalTrainNumber';

  OtnId({super.type = elementType, super.attributes, super.children, super.value});

  factory OtnId.create(String company, String operationalTrainNumber, DateTime startDate,
      {String? additionalTrainNumber}) {
    final otnId = OtnId();
    otnId.children.add(SferaXmlElement(type: _companyAttribute, value: company));
    otnId.children.add(SferaXmlElement(type: _operationalTrainNumberAttribute, value: operationalTrainNumber));
    otnId.children.add(SferaXmlElement(type: _startDateAttribute, value: Format.sferaDate(startDate)));
    if (additionalTrainNumber != null) {
      otnId.children.add(SferaXmlElement(type: _additionalTrainNumberAttribute, value: additionalTrainNumber));
    }

    return otnId;
  }

  String get company => childrenWithType(_companyAttribute).first.value!;

  String get operationalTrainNumber => childrenWithType(_operationalTrainNumberAttribute).first.value!;

  String? get additionalTrainNumber => childrenWithType(_additionalTrainNumberAttribute).firstOrNull?.value;

  DateTime get startDate => DateTime.parse(childrenWithType(_startDateAttribute).first.value!);

  @override
  bool validate() {
    return validateHasChild(_companyAttribute) &&
        validateHasChild(_operationalTrainNumberAttribute) &&
        validateHasChild(_startDateAttribute) &&
        super.validate();
  }

  @override
  toString() {
    return 'OtnId(company: $company, operationalTrainNumber: $operationalTrainNumber, startDate: $startDate, additionalTrainNumber: $additionalTrainNumber)';
  }
}
