import 'package:sfera/src/data/dto/jp_request_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/sp_request_dto.dart';
import 'package:sfera/src/data/dto/tc_request_dto.dart';

class B2gRequestDto extends SferaXmlElementDto {
  static const String elementType = 'B2G_Request';

  B2gRequestDto({super.type = elementType, super.attributes, super.children, super.value});

  factory B2gRequestDto.createJPRequest(JpRequestDto jpRequest) {
    final request = B2gRequestDto();
    request.children.add(jpRequest);
    return request;
  }

  factory B2gRequestDto.createSPRequest(List<SpRequestDto> spRequests) {
    final request = B2gRequestDto();
    request.children.addAll(spRequests);
    return request;
  }

  factory B2gRequestDto.createTCRequest(List<TcRequestDto> tcRequests) {
    final request = B2gRequestDto();
    request.children.addAll(tcRequests);
    return request;
  }
}
