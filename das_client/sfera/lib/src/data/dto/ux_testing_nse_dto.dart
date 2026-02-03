import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class UxTestingNseDto extends NetworkSpecificEventDto {
  static const String elementName = 'uxTesting';

  UxTestingNseDto({super.type, super.attributes, super.children, super.value});

  NetworkSpecificParameterDto? get koa => parameters.withName('koa');

  NetworkSpecificParameterDto? get warn => parameters.withName('warn');

  NetworkSpecificParameterDto? get connectivity => parameters.withName('connectivity');

  @override
  String toString() {
    return 'UxTestingNse{koa: $koa, warn: $warn, connectivity: $connectivity}';
  }
}
