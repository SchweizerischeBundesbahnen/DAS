import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/track_equipment_type.dart';
import 'package:das_client/sfera/src/model/network_specific_area.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile_list.dart';
import 'package:fimber/fimber.dart';

class TrackEquipmentMapper {
  TrackEquipmentMapper._();

  static List<NonStandardTrackEquipmentSegment> parseNonStandardTrackEquipmentSegment(
      List<SegmentProfileList> segmentProfilesLists, List<SegmentProfile> segmentProfiles) {
    final trackEquipments = _parseTrackEquipments(segmentProfilesLists, segmentProfiles);
    trackEquipments.sort((a, b) => a.compareTo(b));

    final openStartSegments = <SferaTrackEquipmentType, _NonStandardTrackEquipment?>{};

    final List<NonStandardTrackEquipmentSegment> segments = [];
    for (final trackEquipment in trackEquipments) {
      if (trackEquipment.startLocation != null && trackEquipment.endLocation != null) {
        segments.add(_createSegmentFromStartsEnds(trackEquipment));
      } else if (trackEquipment.startLocation != null) {
        if (openStartSegments.containsKey(trackEquipment.type)) {
          continue;
        }
        openStartSegments[trackEquipment.type] = trackEquipment;
      } else if (trackEquipment.endLocation != null) {
        final startOfSegment = openStartSegments[trackEquipment.type];
        if (startOfSegment != null) {
          segments.add(_createSegment(startOfSegment, trackEquipment));

          // Clear the pending start after creating a segment
          openStartSegments[trackEquipment.type] = null;
        }
      }
    }

    return segments;
  }

  static NonStandardTrackEquipmentSegment _createSegmentFromStartsEnds(_NonStandardTrackEquipment trackEquipment) =>
      _createSegment(trackEquipment, trackEquipment);

  static NonStandardTrackEquipmentSegment _createSegment(
      _NonStandardTrackEquipment start, _NonStandardTrackEquipment end) {
    return NonStandardTrackEquipmentSegment(
      type: start.type.toTrackEquipmentType(),
      startOrder: SferaModelMapper.calculateOrder(start.index, start.startLocation!),
      endOrder: SferaModelMapper.calculateOrder(end.index, end.endLocation!),
      startKm: start.startKm,
      endKm: end.endKm,
    );
  }

  static List<_NonStandardTrackEquipment> _parseTrackEquipments(
      List<SegmentProfileList> segmentProfilesLists, List<SegmentProfile> segmentProfiles) {
    final trackEquipments = <_NonStandardTrackEquipment>[];
    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfile = segmentProfiles.firstMatch(segmentProfilesLists[segmentIndex]);
      final nonStandardTrackEquipments = segmentProfile.areas?.nonStandardTrackEquipments ?? [];

      final kilometreMap = SferaModelMapper.parseKilometre(segmentProfile);

      trackEquipments.addAll(
        nonStandardTrackEquipments
            .map((element) => _mapToNonStandardTrackEquipment(element, segmentIndex, kilometreMap))
            .where((e) => e != null)
            .cast<_NonStandardTrackEquipment>()
            .toList(),
      );
    }
    return trackEquipments;
  }

  static _NonStandardTrackEquipment? _mapToNonStandardTrackEquipment(NetworkSpecificArea element, int segmentIndex, Map<double, List<double>> kilometreMap) {
    if (element.trackEquipmentTypeWrapper == null) {
      Fimber.w('Encountered nonStandardTrackEquipment track equipment type NSP declaration: ${element.type}');
      return null;
    }

    return _NonStandardTrackEquipment(
      index: segmentIndex,
      type: element.trackEquipmentTypeWrapper!.unwrapped,
      startLocation: element.startLocation,
      endLocation: element.endLocation,
      appliesToWholeSp: element.startEndQualifier == StartEndQualifier.wholeSp,
      startKm: kilometreMap[element.startLocation] ?? [],
      endKm: kilometreMap[element.endLocation] ?? [],
    );
  }
}

/// data class used by mapper to be combined to NonStandardTrackEquipmentSegment
class _NonStandardTrackEquipment implements Comparable {
  _NonStandardTrackEquipment({
    required this.startKm,
    required this.endKm,
    required this.type,
    required this.index,
    this.startLocation,
    this.endLocation,
    this.appliesToWholeSp = false,
  });

  final SferaTrackEquipmentType type;
  final double? startLocation;
  final double? endLocation;
  final List<double> startKm;
  final List<double> endKm;
  final bool appliesToWholeSp;
  final int index;

  @override
  int compareTo(other) {
    final indexComparison = index.compareTo(other.index);
    if (indexComparison != 0) return indexComparison;

    // If indexes are equal, compare the startLocation
    if (startLocation != null && other.startLocation != null) {
      final startLocationComparison = startLocation!.compareTo(other.startLocation!);
      if (startLocationComparison != 0) {
        return startLocationComparison;
      }
    } else if (startLocation != null) {
      return -1;
    } else if (other.startLocation != null) {
      return 1;
    }

    // If both startLocation are equal or not provided, compare the endLocation
    if (endLocation != null && other.endLocation != null) {
      return endLocation!.compareTo(other.endLocation!);
    } else if (endLocation != null) {
      return -1;
    } else if (other.endLocation != null) {
      return 1;
    }

    return 0;
  }
}
