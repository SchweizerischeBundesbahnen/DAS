import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class OperationalIndicationUncodedTextNspDto extends NetworkSpecificParameterDto {
  static const String elementName = 'uncodedText';

  OperationalIndicationUncodedTextNspDto({super.type, super.attributes, super.children, super.value});

  String get text => nspValue;
}
