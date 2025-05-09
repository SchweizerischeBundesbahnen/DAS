import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';

class SpRequestDto extends SferaXmlElementDto {
  static const String elementType = 'SP_Request';

  SpRequestDto({super.type = elementType, super.attributes, super.children, super.value});

  factory SpRequestDto.create(
      {required String id, required String versionMajor, required String versionMinor, required SpZoneDto spZone}) {
    final request = SpRequestDto();
    request.attributes['SP_ID'] = id;
    request.attributes['SP_VersionMajor'] = versionMajor;
    request.attributes['SP_VersionMinor'] = versionMinor;
    request.children.add(spZone);
    return request;
  }
}
