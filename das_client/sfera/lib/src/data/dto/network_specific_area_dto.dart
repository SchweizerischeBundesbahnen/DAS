import 'package:sfera/src/data/dto/amount_tram_signals_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/dto/track_equipment_type_wrapper_dto.dart';

class NetworkSpecificAreaDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'NetworkSpecificArea';
  static const String groupNameElement = 'NSP_GroupName';

  NetworkSpecificAreaDto({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  Iterable<NetworkSpecificParameterDto> get networkSpecificParameters =>
      children.whereType<NetworkSpecificParameterDto>();

  TrackEquipmentTypeWrapperDto? get trackEquipmentTypeWrapper =>
      children.whereType<TrackEquipmentTypeWrapperDto>().firstOrNull;

  AmountTramSignalsDto? get amountTramSignals => children.whereType<AmountTramSignalsDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') && super.validate();
  }
}
