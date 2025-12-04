import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class OperatingDayNsp extends NetworkSpecificParameterDto {
  static const String elementName = 'tms_Operating_Day_Date';

  OperatingDayNsp({super.type, super.attributes, super.children, super.value});

  DateTime? get operatingDay => ParseUtils.tryParseDateTime(attributes['value']!);
}
