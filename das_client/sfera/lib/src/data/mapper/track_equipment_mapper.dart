import 'package:sfera/src/model/journey/track_equipment_segment.dart';
import 'package:sfera/src/data/dto/enums/start_end_qualifier_dto.dart';
import 'package:sfera/src/data/dto/enums/track_equipment_type_dto.dart';
import 'package:sfera/src/data/dto/network_specific_area_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:app/util/comparators.dart';
import 'package:fimber/fimber.dart';
import 'package:sfera/src/data/mapper/mapper_utils.dart';

/// used to map SFERA data to [NonStandardTrackEquipmentSegment]
class TrackEquipmentMapper {
  TrackEquipmentMapper._();

  static List<NonStandardTrackEquipmentSegment> parseNonStandardTrackEquipmentSegment(
      Iterable<SegmentProfileReferenceDto> segmentProfilesLists, Iterable<SegmentProfileDto> segmentProfiles) {
    final trackEquipments = _parseTrackEquipments(segmentProfilesLists, segmentProfiles);
    trackEquipments.sort();

    final openSegments = <SferaTrackEquipmentTypeDto, _NonStandardTrackEquipment?>{};

    final List<NonStandardTrackEquipmentSegment> segments = [];
    for (final trackEquipment in trackEquipments) {
      if (trackEquipment.startLocation != null && trackEquipment.endLocation != null) {
        segments.add(_createSegmentFromStartsEnds(trackEquipment));
      } else if (trackEquipment.startLocation != null) {
        if (openSegments.containsKey(trackEquipment.type)) {
          Fimber.w('Found a track equipment with the same type ${trackEquipment.type} that hasn\'t ended yet');
          continue;
        }
        openSegments[trackEquipment.type] = trackEquipment;
      } else if (trackEquipment.endLocation != null) {
        final startOfSegment = openSegments[trackEquipment.type];
        if (startOfSegment != null) {
          segments.add(_createSegment(startOfSegment, trackEquipment));
          openSegments.remove(trackEquipment.type);
        } else if (trackEquipment.segmentIndex == 0) {
          // got end of track equipment with start outside of train journey
          segments.add(_createSegmentFromEnds(trackEquipment));
        } else {
          Fimber.w('Got end of track equipment segment for type ${trackEquipment.type} without start definition');
        }
      } else if (trackEquipment.appliesToWholeSp) {
        openSegments.putIfAbsent(trackEquipment.type, () => trackEquipment);
      }
    }

    // check open start segments
    for (final trackEquipment in openSegments.values) {
      if (trackEquipment == null) continue;
      segments.add(_createSegmentFromStarts(trackEquipment));
    }

    return segments;
  }

  static NonStandardTrackEquipmentSegment _createSegmentFromStarts(_NonStandardTrackEquipment startTrackEquipment) =>
      _createSegment(startTrackEquipment, null);

  static NonStandardTrackEquipmentSegment _createSegmentFromEnds(_NonStandardTrackEquipment endTrackEquipment) =>
      _createSegment(null, endTrackEquipment);

  static NonStandardTrackEquipmentSegment _createSegmentFromStartsEnds(_NonStandardTrackEquipment trackEquipment) =>
      _createSegment(trackEquipment, trackEquipment);

  static NonStandardTrackEquipmentSegment _createSegment(
      _NonStandardTrackEquipment? start, _NonStandardTrackEquipment? end) {
    if (start == null && end == null) {
      throw Exception('Can not create track equipment segment without at least start or end information.');
    }

    final type = start?.type ?? end?.type;
    return NonStandardTrackEquipmentSegment(
      type: type!.trackEquipmentType,
      startOrder: start?.startLocation != null ? calculateOrder(start!.segmentIndex, start.startLocation!) : null,
      endOrder: end?.endLocation != null ? calculateOrder(end!.segmentIndex, end.endLocation!) : null,
      startKm: start?.startKm ?? [],
      endKm: end?.endKm ?? [],
    );
  }

  static List<_NonStandardTrackEquipment> _parseTrackEquipments(
      Iterable<SegmentProfileReferenceDto> segmentProfilesLists, Iterable<SegmentProfileDto> segmentProfiles) {
    final trackEquipments = <_NonStandardTrackEquipment>[];
    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfile = segmentProfiles.firstMatch(segmentProfilesLists.elementAt(segmentIndex));
      final nonStandardTrackEquipments = segmentProfile.areas?.nonStandardTrackEquipments ?? [];

      final kilometreMap = parseKilometre(segmentProfile);

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

  static _NonStandardTrackEquipment? _mapToNonStandardTrackEquipment(
      NetworkSpecificAreaDto element, int segmentIndex, KilometreMap kilometreMap) {
    if (element.trackEquipmentTypeWrapper == null) {
      Fimber.w('Encountered invalid nonStandardTrackEquipment track equipment type NSP declaration: ${element.type}');
      return null;
    }

    return _NonStandardTrackEquipment(
      segmentIndex: segmentIndex,
      type: element.trackEquipmentTypeWrapper!.unwrapped,
      startLocation: element.startLocation,
      endLocation: element.endLocation,
      appliesToWholeSp: element.startEndQualifier == StartEndQualifierDto.wholeSp,
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
    required this.segmentIndex,
    this.startLocation,
    this.endLocation,
    this.appliesToWholeSp = false,
  });

  final SferaTrackEquipmentTypeDto type;
  final double? startLocation;
  final double? endLocation;
  final List<double> startKm;
  final List<double> endKm;
  final bool appliesToWholeSp;
  final int segmentIndex;

  @override
  int compareTo(other) {
    if (other is! _NonStandardTrackEquipment) return -1;

    final indexComparison = segmentIndex.compareTo(other.segmentIndex);
    if (indexComparison != 0) return indexComparison;

    final startEnd = (start: startLocation?.toInt(), end: endLocation?.toInt());
    final otherStartEnd = (start: other.startLocation?.toInt(), end: other.endLocation?.toInt());
    return StartEndIntComparator.compare(startEnd, otherStartEnd);
  }
}
