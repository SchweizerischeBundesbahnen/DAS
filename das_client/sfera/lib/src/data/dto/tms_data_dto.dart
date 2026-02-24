import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/operating_day_nsp_dto.dart';

class TmsDataNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'TMSData';

  TmsDataNspDto({super.type, super.attributes, super.children, super.value});

  OperatingDayNspDto? get operatingDayNspDto => parameters.whereType<OperatingDayNspDto>().firstOrNull;
}
