import 'package:sfera/src/model/network_specific_parameter.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

abstract class Nsp extends SferaXmlElement {
  static const String elementType = 'NSP';
  static const String groupNameElement = 'NSP_GroupName';

  Nsp({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  Iterable<NetworkSpecificParameter> get parameters => children.whereType<NetworkSpecificParameter>();

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') && validateHasChildOfType<NetworkSpecificParameter>() && super.validate();
  }
}
