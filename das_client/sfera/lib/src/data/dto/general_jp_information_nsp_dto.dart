import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/operating_day_nsp_dto.dart';

class GeneralJpInformationNspDto extends NspDto {
  static const String elementType = 'General_JP_Information_NSP';

  GeneralJpInformationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  OperatingDayNspDto? get operatingDayNsp => children.whereType<OperatingDayNspDto>().firstOrNull;
}
