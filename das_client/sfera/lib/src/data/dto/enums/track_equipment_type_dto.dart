import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/track_equipment_segment.dart';

enum SferaTrackEquipmentTypeDto implements XmlEnum {
  etcsL1ls2TracksWithSingleTrackEquipment(
    xmlValue: 'ETCS-L1LS-2TracksWithSingleTrackEquipment',
    trackEquipmentType: TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment,
  ),
  etcsL1lsSingleTrackNoBlock(
    xmlValue: 'ETCS-L1LS-singleTrackNoBlock',
    trackEquipmentType: TrackEquipmentType.etcsL1lsSingleTrackNoBlock,
  ),
  etcsL2ConvSpeedReversingImpossible(
    xmlValue: 'ETCS-L2-convSpeedReversingImpossible',
    trackEquipmentType: TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
  ),
  etcsL2ExtSpeedReversingPossible(
    xmlValue: 'ETCS-L2-extSpeedReversingPossible',
    trackEquipmentType: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
  ),
  etcsL2ExtSpeedReversingImpossible(
    xmlValue: 'ETCS-L2-extSpeedReversingImpossible',
    trackEquipmentType: TrackEquipmentType.etcsL2ExtSpeedReversingImpossible,
  );

  const SferaTrackEquipmentTypeDto({
    required this.xmlValue,
    required this.trackEquipmentType,
  });

  @override
  final String xmlValue;

  final TrackEquipmentType trackEquipmentType;
}
