import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class FixedPointRelevanceNspDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'fixedPointRelevance';

  bool get fixedPointRelevance => nspValue == '1';
}
