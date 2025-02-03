import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/util/comparators.dart';

/// Represents a segment with non standard track equipment. Standard is bidirectional ETCS L1LS.
class NonStandardTrackEquipmentSegment implements Comparable {
  const NonStandardTrackEquipmentSegment({
    required this.startKm,
    required this.endKm,
    required this.type,
    required this.startOrder,
    required this.endOrder,
  });

  final List<double> startKm;
  final List<double> endKm;
  final TrackEquipmentType type;

  /// Start order of this segment. Nullable as it can start in a journey segment that is not part of the train journey.
  final int? startOrder;

  /// End order of this segment. Nullable as it can end in a journey segment that is not part of the train journey.
  final int? endOrder;

  bool get isEtcsL2Segment => type.isEtcsL2;

  bool get isConventionalSpeed => type.isConventionalSpeed;

  bool get isExtendedSpeed => type.isExtendedSpeed;

  /// checks if the given order is part of this segment.
  bool appliesToOrder(int order) {
    if(startOrder == null && endOrder == null) {
      return true; // applies for whole journey
    } else if (startOrder != null && endOrder != null) {
      return startOrder! <= order && order <= endOrder!;
    } else if (startOrder != null) {
      return startOrder! <= order;
    } else {
      return order <= endOrder!;
    }
  }

  @override
  int compareTo(other) {
    if (other is! NonStandardTrackEquipmentSegment) return -1;

    final startEnd = (start: startOrder, end: endOrder);
    final otherStartEnd = (start: other.startOrder, end: other.endOrder);
    return StartEndIntComparator.compare(startEnd, otherStartEnd);
  }

  @override
  String toString() {
    return 'NonStandardTrackEquipmentSegment(startKm: $startKm, endKm: $endKm, startOrder: $startOrder, endOrder: $endOrder, type: $type)';
  }
}

enum TrackEquipmentType {
  etcsL1ls2TracksWithSingleTrackEquipment,
  etcsL1lsSingleTrackNoBlock,
  etcsL2ConvSpeedReversingImpossible,
  etcsL2ExtSpeedReversingPossible,
  etcsL2ExtSpeedReversingImpossible;

  bool get isEtcsL2 => [
        TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
        TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        TrackEquipmentType.etcsL2ExtSpeedReversingImpossible
      ].contains(this);

  bool get isExtendedSpeed => [
        TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        TrackEquipmentType.etcsL2ExtSpeedReversingImpossible
      ].contains(this);

  bool get isConventionalSpeed => this == etcsL2ConvSpeedReversingImpossible;
}

// extensions

extension BaseDataListSegmentExtension on Iterable<BaseData> {
  Iterable<BaseData> inNonStandardTrackEquipmentSegment(NonStandardTrackEquipmentSegment segment) {
    final dataInsideSegment = where((data) => segment.appliesToOrder(data.order)).toList();
    dataInsideSegment.sort();
    return dataInsideSegment;
  }
}

extension NonStandardTrackEquipmentSegmentsExtension on Iterable<NonStandardTrackEquipmentSegment> {
  Iterable<NonStandardTrackEquipmentSegment> appliesToOrder(int order) =>
      where((segment) => segment.appliesToOrder(order));

  /// Returns all [NonStandardTrackEquipmentSegment] of this list that mark the start of a ETCS level 2 segment
  Iterable<NonStandardTrackEquipmentSegment> get withCABSignalingStart {
    final etcsL2Segments = where((segment) => segment.type.isEtcsL2).toList();
    etcsL2Segments.sort();

    final starts = <NonStandardTrackEquipmentSegment>[];
    for (int i = 0; i < etcsL2Segments.length; i++) {
      final segment = etcsL2Segments[i];

      // ignore segments without start
      if (segment.startOrder == null) continue;

      if (i == 0 || segment.startOrder != etcsL2Segments[i - 1].endOrder) {
        starts.add(segment);
      }
    }

    return starts;
  }

  /// Returns all [NonStandardTrackEquipmentSegment] of this list that mark the end of a ETCS level 2 segment
  Iterable<NonStandardTrackEquipmentSegment> get withCABSignalingEnd {
    final etcsL2Segments = where((segment) => segment.type.isEtcsL2).toList();
    etcsL2Segments.sort();

    final ends = <NonStandardTrackEquipmentSegment>[];
    for (int i = 0; i < etcsL2Segments.length; i++) {
      final segment = etcsL2Segments[i];

      // ignore segments without end
      if (segment.endOrder == null) continue;

      if (i == etcsL2Segments.length - 1 || segment.endOrder != etcsL2Segments[i + 1].startOrder) {
        ends.add(segment);
      }
    }

    return ends;
  }
}
