import 'package:sfera/src/data/dto/local_regulation_content_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_title_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class LocalRegulationNspDto extends TafTapLocationNspDto {
  static const String elementNameStart = 'localRegulation';

  LocalRegulationNspDto({super.type, super.attributes, super.children, super.value});

  Iterable<LocalRegulationTitleNspDto> get titles => children.whereType<LocalRegulationTitleNspDto>();

  Iterable<LocalRegulationContentNspDto> get contents => children.whereType<LocalRegulationContentNspDto>();
}
