import 'package:das_client/sfera/src/model/amount_tram_signals.dart';
import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/track_equipment_type_wrapper.dart';
import 'package:das_client/util/util.dart';

class NetworkSpecificArea extends SferaXmlElement {
  static const String elementType = 'NetworkSpecificArea';
  static const String groupNameElement = 'NSP_GroupName';

  NetworkSpecificArea({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  StartEndQualifier? get startEndQualifier =>
      XmlEnum.valueOf<StartEndQualifier>(StartEndQualifier.values, attributes['startEndQualifier']);

  double? get startLocation => Util.tryParseDouble(attributes['startLocation']);

  double? get endLocation => Util.tryParseDouble(attributes['endLocation']);

  Iterable<NetworkSpecificParameter> get networkSpecificParameters => children.whereType<NetworkSpecificParameter>();

  TrackEquipmentTypeWrapper? get trackEquipmentTypeWrapper =>
      children.whereType<TrackEquipmentTypeWrapper>().firstOrNull;

  AmountTramSignals? get amountTramSignals => children.whereType<AmountTramSignals>().firstOrNull;

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') && validateHasAttribute('startEndQualifier') && super.validate();
  }
}
