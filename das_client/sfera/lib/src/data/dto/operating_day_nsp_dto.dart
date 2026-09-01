import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class OperatingDayNspDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'operatingDay';

  DateTime? get operatingDay => ParseUtils.tryParseDateTime(attributes['value']!);
}
