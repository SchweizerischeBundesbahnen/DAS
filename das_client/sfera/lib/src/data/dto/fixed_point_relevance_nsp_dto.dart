import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class FixedPointRelevanceNspDto extends NetworkSpecificParameterDto {
  static const String elementName = 'fixedPointRelevance';

  FixedPointRelevanceNspDto({super.type, super.attributes, super.children, super.value});

  bool get fixedPointRelevance => nspValue == '1';
}
