import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/multilingual_text.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';
import 'package:das_client/sfera/src/model/timing_point.dart';
import 'package:fimber/fimber.dart';

class SferaModelMapper {
  SferaModelMapper._();

  static const int _hundredThousand = 100000;

  static Journey mapToJourney(JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles) {
    try {
      return _mapToJourney(journeyProfile, segmentProfiles);
    } catch (e, s) {
      Fimber.e('Error mapping journey-/segment profiles to journey:', ex: e, stacktrace: s);
      return Journey.invalid();
    }
  }

  static Journey _mapToJourney(JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles) {
    final journeyData = <BaseData>[];

    final segmentProfilesLists = journeyProfile.segmentProfilesLists.toList();
    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfileList = segmentProfilesLists[segmentIndex];
      final segmentProfile = segmentProfiles
          .where((it) =>
              it.id == segmentProfileList.spId &&
              it.versionMajor == segmentProfileList.versionMajor &&
              it.versionMinor == segmentProfileList.versionMinor)
          .first;

      final kilometreMap = _parseKilometre(segmentProfile);
      final tafTapLocations = _parseTafTapLocation(segmentProfile);
      final timingPoints = _parseTimingPoints(segmentProfile);

      for (final tpConstraint in segmentProfileList.timingPointsContraints) {
        final tpId = tpConstraint.timingPointReference.tpIdReference.tpId;
        final timingPoint = timingPoints.where((it) => it.id == tpId).first;
        final tafTapLocation = tafTapLocations
            .where((it) =>
                it.locationIdent.countryCodeISO == timingPoint.locationReference?.countryCodeISO &&
                it.locationIdent.locationPrimaryCode == timingPoint.locationReference?.locationPrimaryCode)
            .first;

        journeyData.add(ServicePoint(
            name: _localizedStringFromMultilingualText(tafTapLocation.locationNames),
            order: _calculateOrder(segmentIndex, timingPoint.location),
            kilometre: kilometreMap[timingPoint.location]));
      }
    }

    return Journey(metadata: Metadata(), data: journeyData);
  }

  static int _calculateOrder(int segmentIndex, double location) {
    return (segmentIndex * _hundredThousand + location).toInt();
  }

  static LocalizedString _localizedStringFromMultilingualText(Iterable<MultilingualText> multilingualText) {
    return LocalizedString(
      de: multilingualText.where((it) => it.language == 'de').firstOrNull?.messageString,
      fr: multilingualText.where((it) => it.language == 'fr').firstOrNull?.messageString,
      it: multilingualText.where((it) => it.language == 'it').firstOrNull?.messageString,
    );
  }

  static Map<double, double> _parseKilometre(SegmentProfile segmentProfile) {
    final kilometreMap = <double, double>{};
    for (final point in segmentProfile.contextInformation) {
      for (final kilometreReferencePoint in point.kilometreReferencePoints) {
        kilometreMap[kilometreReferencePoint.location] = kilometreReferencePoint.kmReference.kmRef;
      }
    }
    return kilometreMap;
  }

  static List<TafTapLocation> _parseTafTapLocation(SegmentProfile segmentProfile) {
    final locations = <TafTapLocation>[];
    for (final area in segmentProfile.areas) {
      locations.addAll(area.tafTapLocations);
    }
    return locations;
  }

  static List<TimingPoint> _parseTimingPoints(SegmentProfile segmentProfile) {
    final timingPoints = <TimingPoint>[];
    for (final point in segmentProfile.points) {
      timingPoints.addAll(point.timingPoints);
    }
    return timingPoints;
  }
}
