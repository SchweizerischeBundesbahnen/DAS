import 'package:sfera/src/data/dto/enums/handshake_reject_reason_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';

class HandshakeRejectDto extends SferaXmlElementDto {
  static const String elementType = 'HandshakeReject';

  HandshakeRejectDto({super.type = elementType, super.attributes, super.children, super.value});

  SpZoneDto? get spZone => children.whereType<SpZoneDto>().firstOrNull;

  String? get atotsId => attributes['ATOTS_ID'];

  HandshakeRejectReasonDto? get handshakeRejectReason =>
      XmlEnum.valueOf(HandshakeRejectReasonDto.values, childrenWithType('HandshakeRejectReason').first.value);

  @override
  bool validate() {
    return validateHasChild('HandshakeRejectReason') && super.validate();
  }
}
