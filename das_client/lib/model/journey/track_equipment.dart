class NonStandardTrackEquipmentSegment {
  const NonStandardTrackEquipmentSegment({
    required this.startKm,
    required this.endKm,
    required this.type,
    required this.startOrder,
    required this.endOrder,
  });

  final List<double> startKm;
  final List<double> endKm;
  final int startOrder;
  final int endOrder;
  final TrackEquipmentType type;

  bool appliesToOrder(int order) => startOrder <= order && order <= endOrder;
}

enum TrackEquipmentType {
  etcsL1ls2TracksWithSingleTrackEquipment,
  etcsL2ConvSpeedReversingImpossible,
  etcsL2ExtSpeedReversingPossible,
  etcsL2ExtSpeedReversingImpossible;

  bool isEtcsL2() => [
        TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
        TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        TrackEquipmentType.etcsL2ExtSpeedReversingImpossible
      ].contains(this);
}

// extensions

extension NonStandardTrackEquipmentSegmentsExtension on List<NonStandardTrackEquipmentSegment> {
  List<NonStandardTrackEquipmentSegment> appliesToOrder(int order) =>
      where((segment) => segment.appliesToOrder(order)).toList();

  /// Returns all [NonStandardTrackEquipmentSegment] of this list that mark the start of a ETCS level 2 segment
  List<NonStandardTrackEquipmentSegment> get withCABSignalingStart {
    final etcsL2Segments = where((segment) => segment.type.isEtcsL2()).toList();
    etcsL2Segments.sort((a, b) => a.startOrder.compareTo(b.startOrder));
    final starts = <NonStandardTrackEquipmentSegment>[];

    for (int i = 0; i < etcsL2Segments.length; i++) {
      if (i == 0 || etcsL2Segments[i].startOrder != etcsL2Segments[i - 1].endOrder) {
        starts.add(etcsL2Segments[i]);
      }
    }

    return starts;
  }

  /// Returns all [NonStandardTrackEquipmentSegment] of this list that mark the end of a ETCS level 2 segment
  List<NonStandardTrackEquipmentSegment> get withCABSignalingEnd {
    final etcsL2Segments = where((segment) => segment.type.isEtcsL2()).toList();
    etcsL2Segments.sort((a, b) => a.startOrder.compareTo(b.startOrder));
    final ends = <NonStandardTrackEquipmentSegment>[];

    for (int i = 0; i < etcsL2Segments.length; i++) {
      if (i == etcsL2Segments.length - 1 || etcsL2Segments[i].endOrder != etcsL2Segments[i + 1].startOrder) {
        ends.add(etcsL2Segments[i]);
      }
    }

    return ends;
  }
}
