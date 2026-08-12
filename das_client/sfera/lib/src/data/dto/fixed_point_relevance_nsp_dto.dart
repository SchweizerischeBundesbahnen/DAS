import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

/// Network Specific Parameter attribute name is 'newSpeed'
/// In domain, often referred to as 'VProSpeed'
/// In application layer, referred to as calculatedSpeed, since this speed is calculated shortly before the journey.
class FixedPointRelevanceNspDto extends NetworkSpecificParameterDto {
  static const String elementName = 'fixedPointRelevance';

  FixedPointRelevanceNspDto({super.type, super.attributes, super.children, super.value});

  bool get fixedPointRelevance => nspValue == '1';
}
