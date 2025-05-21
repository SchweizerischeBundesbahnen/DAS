import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TcRequestDto extends SferaXmlElementDto {
  static const String elementType = 'TC_Request';

  TcRequestDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TcRequestDto.create({
    required String id,
    required String versionMajor,
    required String versionMinor,
    required String ruId,
  }) {
    final request = TcRequestDto();
    request.attributes['TC_ID'] = id;
    request.attributes['TC_VersionMajor'] = versionMajor;
    request.attributes['TC_VersionMinor'] = versionMinor;
    request.children.add(SferaXmlElementDto(type: 'TC_RU_ID', value: ruId));
    return request;
  }
}
