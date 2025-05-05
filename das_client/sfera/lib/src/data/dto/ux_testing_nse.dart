import 'package:sfera/src/data/dto/network_specific_event.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';

class UxTestingNse extends NetworkSpecificEvent {
  static const String elementName = 'uxTesting';

  UxTestingNse({super.type, super.attributes, super.children, super.value});

  NetworkSpecificParameter? get koa => parameters.withName('koa');

  NetworkSpecificParameter? get warn => parameters.withName('warn');

  @override
  String toString() {
    return 'UxTestingNse{koa: $koa, warn: $warn}';
  }
}
