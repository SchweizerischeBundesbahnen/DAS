import 'package:das_client/sfera/src/model/network_specific_event.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/util/annotations/non_production.dart';

@nonProduction
class UxTestingNse extends NetworkSpecificEvent {
  static const String elementName = 'uxTesting';

  UxTestingNse({super.type, super.attributes, super.children, super.value});

  NetworkSpecificParameter? get koa => parameters.withName('koa');

  NetworkSpecificParameter? get warn => parameters.withName('warn');
}
