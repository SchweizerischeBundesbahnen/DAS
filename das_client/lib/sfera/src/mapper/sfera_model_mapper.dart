import 'package:collection/collection.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:das_client/sfera/src/mapper/track_equipment_mapper.dart';
import 'package:das_client/sfera/src/model/enums/length_type.dart';
import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/stop_skip_pass.dart';
import 'package:das_client/sfera/src/model/enums/taf_tap_location_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/multilingual_text.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';
import 'package:fimber/fimber.dart';

class SferaModelMapper {
  SferaModelMapper._();

  static const int _hundredThousand = 100000;
  static const String _bracketStationNspName = 'bracketStation';
  static const String _bracketStationMainStationNspName = 'mainStation';
  static const String _protectionSectionNspFacultativeName = 'facultative';
  static const String _protectionSectionNspLengthTypeName = 'lengthType';

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
    final tafTapLocations =
        segmentProfiles.map((it) => it.areas).whereNotNull().expand((it) => it.tafTapLocations).toList();

    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfileList = segmentProfilesLists[segmentIndex];
      final segmentProfile = segmentProfiles.firstMatch(segmentProfileList);

      final kilometreMap = parseKilometre(segmentProfile);

      final curvePoints = _parseCurvePoints(segmentProfile, segmentIndex, kilometreMap);
      final curveBeginPoints = curvePoints.where((curve) => curve.curvePointType == CurvePointType.begin);
      journeyData.addAll(curveBeginPoints);

      final signals = _parseSignals(segmentProfile, segmentIndex, kilometreMap);
      journeyData.addAll(signals);

      final timingPoints = segmentProfile.points?.timingPoints.toList() ?? [];

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
          order: calculateOrder(segmentIndex, timingPoint.location),
          mandatoryStop: tpConstraint.stoppingPointInformation?.stopType?.mandatoryStop ?? true,
          isStop: tpConstraint.stopSkipPass == StopSkipPass.stoppingPoint,
          isStation: tafTapLocation.locationType != TafTapLocationType.stoppingLocation,
          bracketStation: _parseBracketStation(tafTapLocations, tafTapLocation),
          kilometre: kilometreMap[timingPoint.location] ?? [],
        ));
      }

      _parseAndAddProtectionSections(journeyData, segmentIndex, segmentProfile, kilometreMap);
    }

    final additionalSpeedRestrictions = _parseAdditionalSpeedRestrictions(journeyProfile, segmentProfiles);
    for (final restriction in additionalSpeedRestrictions) {
      journeyData.add(AdditionalSpeedRestrictionData(
          restriction: restriction, order: restriction.orderFrom, kilometre: [restriction.kmFrom]));

      if (restriction.needsEndMarker(journeyData)) {
        journeyData.add(AdditionalSpeedRestrictionData(
            restriction: restriction, order: restriction.orderTo, kilometre: [restriction.kmTo]));
      }
    }

    final trackEquipmentSegments =
        TrackEquipmentMapper.parseNonStandardTrackEquipmentSegment(segmentProfilesLists, segmentProfiles);
    journeyData.addAll(_cabSignalingStart(trackEquipmentSegments));
    journeyData.addAll(_cabSignalingEnd(trackEquipmentSegments));

    journeyData.sort();

    final servicePoints = journeyData.where((it) => it.type == Datatype.servicePoint).toList();
    return Journey(
      metadata: Metadata(
        nextStop: servicePoints.length > 1 ? servicePoints[1] as ServicePoint : null,
        currentPosition: journeyData.first,
        additionalSpeedRestrictions: additionalSpeedRestrictions,
        routeStart: journeyData.firstOrNull,
        routeEnd: journeyData.lastOrNull,
        nonStandardTrackEquipmentSegment: trackEquipmentSegments,
      ),
      data: journeyData,
    );
  }

  static List<AdditionalSpeedRestriction> _parseAdditionalSpeedRestrictions(
      JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles) {
    final List<AdditionalSpeedRestriction> result = [];
    final now = DateTime.now();
    final segmentProfilesLists = journeyProfile.segmentProfilesLists.toList();

    int? startSegmentIndex;
    int? endSegmentIndex;
    double? startLocation;
    double? endLocation;

    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfileList = segmentProfilesLists[segmentIndex];

      for (final asrTemporaryConstrain in segmentProfileList.asrTemporaryConstrains) {
        // TODO: Es werden Langsamfahrstellen von 30min vor Start der Fahrt (betriebliche Zeit) bis 30min nach Ende der Fahrt (betriebliche Zeit) angezeigt.
        if (asrTemporaryConstrain.startTime != null && asrTemporaryConstrain.startTime!.isAfter(now) ||
            asrTemporaryConstrain.endTime != null && asrTemporaryConstrain.endTime!.isBefore(now)) {
          continue;
        }

        switch (asrTemporaryConstrain.startEndQualifier) {
          case StartEndQualifier.starts:
            startLocation = asrTemporaryConstrain.startLocation;
            startSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.startsEnds:
            startLocation = asrTemporaryConstrain.startLocation;
            startSegmentIndex = segmentIndex;
            continue next;
          next:
          case StartEndQualifier.ends:
            endLocation = asrTemporaryConstrain.endLocation;
            endSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.wholeSp:
            break;
        }

        if (startSegmentIndex != null && endSegmentIndex != null && startLocation != null && endLocation != null) {
          final startSegment = segmentProfiles.firstMatch(segmentProfilesLists[startSegmentIndex]);
          final endSegment = segmentProfiles.firstMatch(segmentProfilesLists[endSegmentIndex]);

          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);

          final startOrder = calculateOrder(startSegmentIndex, startLocation);
          final endOrder = calculateOrder(endSegmentIndex, endLocation);

          result.add(AdditionalSpeedRestriction(
              kmFrom: startKilometreMap[startLocation]!.first,
              kmTo: endKilometreMap[endLocation]!.first,
              orderFrom: startOrder,
              orderTo: endOrder,
              speed: asrTemporaryConstrain.additionalSpeedRestriction?.asrSpeed));

          startSegmentIndex = null;
          endSegmentIndex = null;
          startLocation = null;
          endLocation = null;
        }
      }
    }

    if (startSegmentIndex != null || endSegmentIndex != null || startLocation != null || endLocation != null) {
      Fimber.w('Incomplete additional speed restriction found: '
          'startSegmentIndex: $startSegmentIndex, endSegmentIndex: $endSegmentIndex, '
          'startLocation: $startLocation, endLocation: $endLocation');
    }

    return result;
  }

  static Iterable<Signal> _parseSignals(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final signals = segmentProfile.points?.signals ?? [];
    return signals.map((signal) {
      return Signal(
        visualIdentifier: signal.physicalCharacteristics?.visualIdentifier,
        functions: signal.functions.map((function) => SignalFunction.from(function.value!)).toList(),
        order: calculateOrder(segmentIndex, signal.id.location),
        kilometre: kilometreMap[signal.id.location] ?? [],
      );
    });
  }

  static int calculateOrder(int segmentIndex, double location) {
    return (segmentIndex * _hundredThousand + location).toInt();
  }

  static LocalizedString _localizedStringFromMultilingualText(Iterable<MultilingualText> multilingualText) {
    return LocalizedString(
      de: multilingualText.where((it) => it.language == 'de').firstOrNull?.messageString,
      fr: multilingualText.where((it) => it.language == 'fr').firstOrNull?.messageString,
      it: multilingualText.where((it) => it.language == 'it').firstOrNull?.messageString,
    );
  }

  static Map<double, List<double>> parseKilometre(SegmentProfile segmentProfile) {
    final kilometreMap = <double, List<double>>{};
    if (segmentProfile.contextInformation != null) {
      for (final kilometreReferencePoint in segmentProfile.contextInformation!.kilometreReferencePoints) {
        if (!kilometreMap.containsKey(kilometreReferencePoint.location)) {
          kilometreMap[kilometreReferencePoint.location] = [];
        }
        kilometreMap[kilometreReferencePoint.location]!.add(kilometreReferencePoint.kmReference.kmRef);
      }
    }
    return kilometreMap;
  }

  static void _parseAndAddProtectionSections(List<BaseData> journeyData, int segmentIndex,
      SegmentProfile segmentProfile, Map<double, List<double>> kilometreMap) {
    if (segmentProfile.characteristics?.currentLimitation != null) {
      final currentLimitation = segmentProfile.characteristics!.currentLimitation!;

      final protectionSectionNsps = segmentProfile.points?.protectionSectionNsp ?? [];

      for (final currentLimitationChange in currentLimitation.currentLimitationChanges) {
        if (currentLimitationChange.maxCurValue == '0') {
          final protectionSectionNsp =
              protectionSectionNsps.where((it) => it.location == currentLimitationChange.location).firstOrNull;

          final isOptional = protectionSectionNsp?.parameters
              .where((it) => it.name == _protectionSectionNspFacultativeName)
              .firstOrNull;

          final isLong = protectionSectionNsp?.parameters
              .where((it) => it.name == _protectionSectionNspLengthTypeName)
              .firstOrNull;

          journeyData.add(ProtectionSection(
              isOptional: isOptional != null ? bool.parse(isOptional.nspValue) : false,
              isLong: isLong != null ? XmlEnum.valueOf(LengthType.values, isLong.nspValue) == LengthType.long : false,
              order: calculateOrder(segmentIndex, currentLimitationChange.location),
              kilometre: kilometreMap[currentLimitationChange.location]!));
        }
      }
    }
  }

  static BracketStation? _parseBracketStation(List<TafTapLocation> allLocations, TafTapLocation tafTapLocation) {
    for (final tafTapLocationNsp in tafTapLocation.nsp) {
      if (tafTapLocationNsp.name == _bracketStationNspName) {
        final mainStationNsp = tafTapLocationNsp.networkSpecificParameters
            .where((it) => it.name == _bracketStationMainStationNspName)
            .firstOrNull;
        if (mainStationNsp == null) {
          Fimber.w('Encountered bracket station without main station NSP declaration: $tafTapLocation');
        } else {
          final countryCode = mainStationNsp.nspValue.substring(0, 2);
          final primaryCode = int.parse(mainStationNsp.nspValue.substring(2, 6));
          final mainStation = allLocations
              .where((it) =>
                  it.locationIdent.countryCodeISO == countryCode && it.locationIdent.locationPrimaryCode == primaryCode)
              .firstOrNull;
          if (mainStation == null) {
            Fimber.w('Failed to resolve main station for bracket station: $tafTapLocation');
          } else {
            return BracketStation(
                mainStationAbbreviation: mainStation != tafTapLocation ? mainStation.abbreviation : null);
          }
        }
      }
    }

    return null;
  }

  static List<CurvePoint> _parseCurvePoints(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final curvePointsNsp = segmentProfile.points?.curvePointsNsp ?? [];
    return curvePointsNsp.map<CurvePoint>((curvePointNsp) {
      final curvePointTypeValue = curvePointNsp.parameters.withName('curvePointType')?.nspValue;
      final curveTypeValue = curvePointNsp.parameters.withName('curveType')?.nspValue;
      return CurvePoint(
        order: calculateOrder(segmentIndex, curvePointNsp.location),
        kilometre: kilometreMap[curvePointNsp.location] ?? [],
        curvePointType: curvePointTypeValue != null ? CurvePointType.from(curvePointTypeValue) : null,
        curveType: curveTypeValue != null ? CurveType.from(curveTypeValue) : null,
        comment: curvePointNsp.parameters.withName('comment')?.nspValue,
      );
    }).toList();
  }

  static Iterable<CABSignaling> _cabSignalingStart(Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    return trackEquipmentSegments.withCABSignalingStart
        .map((element) => CABSignaling(isStart: true, order: element.startOrder!, kilometre: element.startKm));
  }

  static Iterable<CABSignaling> _cabSignalingEnd(Iterable<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    return trackEquipmentSegments.withCABSignalingEnd
        .map((element) => CABSignaling(isStart: false, order: element.endOrder!, kilometre: element.endKm));
  }
}
