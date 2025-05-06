import 'package:sfera/src/data/dto/enums/communication_network_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';

class CommunicationNetworkDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'CommunicationNetwork';

  CommunicationNetworkDto({super.type = elementType, super.attributes, super.children, super.value});

  SferaCommunicationNetworkTypeDto get communicationNetworkType =>
      XmlEnum.valueOf(SferaCommunicationNetworkTypeDto.values, attributes['communicationNetworkType'])!;

  @override
  double get startLocation => super.startLocation!;

  @override
  double get endLocation => super.endLocation!;

  @override
  bool validate() {
    return validateHasAttribute('startLocation') &&
        validateHasAttribute('endLocation') &&
        validateHasAttribute('communicationNetworkType') &&
        super.validate();
  }
}
