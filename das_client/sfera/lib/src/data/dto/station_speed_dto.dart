import 'package:sfera/src/data/dto/speeds_dto.dart';

class StationSpeedDto extends SpeedsDto {
  static const String elementType = 'stationSpeed';

  StationSpeedDto({super.type = elementType, super.attributes, super.children, super.value});
}
