import 'package:sfera/src/data/dto/amount_tram_signals.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element.dart';
import 'package:sfera/src/data/dto/track_equipment_type_wrapper.dart';

class NetworkSpecificArea extends SferaSegmentXmlElement {
  static const String elementType = 'NetworkSpecificArea';
  static const String groupNameElement = 'NSP_GroupName';

  NetworkSpecificArea({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  Iterable<NetworkSpecificParameter> get networkSpecificParameters => children.whereType<NetworkSpecificParameter>();

  TrackEquipmentTypeWrapper? get trackEquipmentTypeWrapper =>
      children.whereType<TrackEquipmentTypeWrapper>().firstOrNull;

  AmountTramSignals? get amountTramSignals => children.whereType<AmountTramSignals>().firstOrNull;

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') && super.validate();
  }
}
