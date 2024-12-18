import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum SferaTrackEquipmentType implements XmlEnum {
  etcsL1ls2TracksWithSingleTrackEquipment(
    xmlValue: 'ETCS-L1LS-2TracksWithSingleTrackEquipment',
    trackEquipmentType: TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment,
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

  const SferaTrackEquipmentType({
    required this.xmlValue,
    required this.trackEquipmentType,
  });

  @override
  final String xmlValue;

  final TrackEquipmentType trackEquipmentType;
}
