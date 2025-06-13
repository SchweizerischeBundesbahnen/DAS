import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class IdNetworkSpecificParameterDto extends NetworkSpecificParameterDto {
  static const String elementName = 'id';

  IdNetworkSpecificParameterDto({super.type, super.attributes, super.children, super.value});

  String get id => nspValue;
}
