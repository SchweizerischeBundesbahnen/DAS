import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class NetworkSpecificArea extends SferaXmlElement {
  static const String elementType = 'NetworkSpecificArea';
  static const String _trackEquipmentTypeName = 'trackEquipmentType';

  NetworkSpecificArea({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  StartEndQualifier? get startEndQualifier =>
      XmlEnum.valueOf<StartEndQualifier>(StartEndQualifier.values, attributes['startEndQualifier']);

  double? get startLocation => _parseOrNull(attributes['startLocation']);

  double? get endLocation => _parseOrNull(attributes['endLocation']);

  Iterable<NetworkSpecificParameter> get networkSpecificParameters => children.whereType<NetworkSpecificParameter>();

  NetworkSpecificParameter? get trackEquipmentType =>
      children.whereType<NetworkSpecificParameter>().where((it) => it.name == _trackEquipmentTypeName).firstOrNull;

  double? _parseOrNull(String? source) {
    return source != null ? double.parse(source) : null;
  }

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('startEndQualifier') && super.validate();
  }
}
