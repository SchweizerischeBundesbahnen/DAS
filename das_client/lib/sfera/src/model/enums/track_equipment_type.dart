import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum SferaTrackEquipmentType implements XmlEnum {
  etcsL1ls2TracksWithSingleTrackEquipment(xmlValue: 'ETCS-L1LS-2TracksWithSingleTrackEquipment'),
  etcsL2ConvSpeedReversingImpossible(xmlValue: 'ETCS-L2-convSpeedReversingImpossible'),
  etcsL2ExtSpeedReversingPossible(xmlValue: 'ETCS-L2-extSpeedReversingPossible'),
  etcsL2ExtSpeedReversingImpossible(xmlValue: 'ETCS-L2-extSpeedReversingImpossible');

  const SferaTrackEquipmentType({
    required this.xmlValue,
  });

  TrackEquipmentType toTrackEquipmentType() {
    switch(this) {
      case SferaTrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment:
        return TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment;
      case SferaTrackEquipmentType.etcsL2ConvSpeedReversingImpossible:
        return TrackEquipmentType.etcsL2ConvSpeedReversingImpossible;
      case SferaTrackEquipmentType.etcsL2ExtSpeedReversingPossible:
        return TrackEquipmentType.etcsL2ExtSpeedReversingPossible;
      case SferaTrackEquipmentType.etcsL2ExtSpeedReversingImpossible:
        return TrackEquipmentType.etcsL2ExtSpeedReversingImpossible;
    }
  }

  @override
  final String xmlValue;
}
