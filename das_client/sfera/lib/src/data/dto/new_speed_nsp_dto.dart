import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

/// Network Specific Parameter attribute name is 'newSpeed'
/// In domain, often referred to as 'VProSpeed'
/// In application layer, referred to as calculatedSpeed, since this speed is calculated shortly before the journey.
class NewSpeedNetworkSpecificParameterDto extends NetworkSpecificParameterDto {
  static const String elementName = 'newSpeed';

  NewSpeedNetworkSpecificParameterDto({super.type, super.attributes, super.children, super.value});

  String get speed => nspValue;
}
