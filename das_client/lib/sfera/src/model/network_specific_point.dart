import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/sp_generic_point.dart';

class NetworkSpecificPoint extends SpGenericPoint {
  static const String elementType = 'NetworkSpecificPoint';

  NetworkSpecificPoint({required super.type, super.attributes, super.children, super.value});

  String? get name => attributes['name'];

  Iterable<NetworkSpecificParameter> get parameters => children.whereType<NetworkSpecificParameter>();

  @override
  bool validate() {
    return validateHasChildOfType<NetworkSpecificParameter>() && super.validate();
  }
}