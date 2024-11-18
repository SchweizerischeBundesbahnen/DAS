import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:das_client/sfera/src/model/enums/stop_skip_pass.dart';
import 'package:das_client/sfera/src/model/enums/taf_tap_location_type.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/multilingual_text.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
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
      final tafTapLocations = segmentProfile.areas.expand((it) => it.tafTapLocations).toList();
      final timingPoints = segmentProfile.points.expand((it) => it.timingPoints).toList();

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
            mandatoryStop: tpConstraint.stoppingPointInformation?.stopType?.mandatoryStop ?? true,
            isStop: tpConstraint.stopSkipPass == StopSkipPass.stoppingPoint,
            isHalt: tafTapLocation.locationType == TafTapLocationType.stoppingLocation,
            kilometre: kilometreMap[timingPoint.location] ?? []));
      }
    }

    journeyData.sort((a, b) => a.order.compareTo(b.order));

    final servicePoints = journeyData.where((it) => it.type == Datatype.servicePoint).toList();

    return Journey(
        metadata: Metadata(
            nextStop: servicePoints.length > 1 ? servicePoints[1] as ServicePoint : null,
            currentPosition: journeyData.first),
        data: journeyData);
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

  static Map<double, List<double>> _parseKilometre(SegmentProfile segmentProfile) {
    final kilometreMap = <double, List<double>>{};
    for (final point in segmentProfile.contextInformation) {
      for (final kilometreReferencePoint in point.kilometreReferencePoints) {
        if (!kilometreMap.containsKey(kilometreReferencePoint.location)) {
          kilometreMap[kilometreReferencePoint.location] = [];
        }
        kilometreMap[kilometreReferencePoint.location]!.add(kilometreReferencePoint.kmReference.kmRef);
      }
    }
    return kilometreMap;
  }
}
