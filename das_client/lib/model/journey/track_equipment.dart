import 'package:collection/collection.dart';

class TrackEquipment {
  TrackEquipment({
    required this.type,
    this.startLocation,
    this.endLocation,
    this.appliesToWholeSp = false,
  });

  final double? startLocation;
  final double? endLocation;
  final bool appliesToWholeSp;
  final TrackEquipmentType type;

  bool isOnLocation(double location) {
    if (appliesToWholeSp) {
      return true;
    } else if (startLocation != null && endLocation != null) {
      return startLocation! <= location && location <= endLocation!;
    } else if (startLocation != null) {
      return startLocation! <= location;
    } else if (endLocation != null) {
      return location <= endLocation!;
    }
    return false;
  }
}

enum TrackEquipmentType {
  etcsL1ls2TracksWithSingleTrackEquipment('ETCS-L1LS-2TracksWithSingleTrackEquipment'),
  etcsL2ConvSpeedReversingImpossible('ETCS-L2-convSpeedReversingImpossible'),
  etcsL2ExtSpeedReversingPossible('ETCS-L2-extSpeedReversingPossible'),
  etcsL2ExtSpeedReversingImpossible('ETCS-L2-extSpeedReversingImpossible');

  const TrackEquipmentType(this.value);

  final String value;

  static TrackEquipmentType? from(String value) {
    return values.firstWhereOrNull(
      (e) => e.value.toLowerCase() == value.toLowerCase()
    );
  }
}

// extensions

extension TrackEquipmentsExtension on Iterable<TrackEquipment> {
  Iterable<TrackEquipment> whereOnLocation(double location) =>
      where((trackEquipment) => trackEquipment.isOnLocation(location));
}
