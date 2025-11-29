import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/operating_day_nsp.dart';

class GeneralJpInformationNspDto extends NspDto {
  static const String elementType = 'General_JP_Information_NSP';

  OperatingDayNsp? get operatingDayNsp => children.whereType<OperatingDayNsp>().firstOrNull;

  GeneralJpInformationNspDto({super.type = elementType, super.attributes, super.children, super.value});
}
