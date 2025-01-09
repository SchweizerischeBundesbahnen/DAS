import 'package:collection/collection.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/balise.dart' as journey_balise;
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:das_client/model/journey/velocity.dart';
import 'package:das_client/model/journey/whistles.dart';
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
import 'package:das_client/sfera/src/model/speeds.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:fimber/fimber.dart';

class SferaModelMapper {
  SferaModelMapper._();

  static const int _hundredThousand = 100000;
  static const String _bracketStationNspName = 'bracketStation';
  static const String _bracketStationMainStationNspName = 'mainStation';
  static const String _protectionSectionNspFacultativeName = 'facultative';
  static const String _protectionSectionNspLengthTypeName = 'lengthType';

  static Journey mapToJourney(JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles,
      List<TrainCharacteristics> trainCharacteristics) {
    try {
      return _mapToJourney(journeyProfile, segmentProfiles, trainCharacteristics);
    } catch (e, s) {
      Fimber.e('Error mapping journey-/segment profiles to journey:', ex: e, stacktrace: s);
      return Journey.invalid();
    }
  }

  static Journey _mapToJourney(JourneyProfile journeyProfile, List<SegmentProfile> segmentProfiles,
      List<TrainCharacteristics> trainCharacteristics) {
    final journeyData = <BaseData>[];

    final segmentProfilesLists = journeyProfile.segmentProfilesLists.toList();
    final tafTapLocations = segmentProfiles.map((it) => it.areas).nonNulls.expand((it) => it.tafTapLocations).toList();

    for (int segmentIndex = 0; segmentIndex < segmentProfilesLists.length; segmentIndex++) {
      final segmentProfileList = segmentProfilesLists[segmentIndex];
      final segmentProfile = segmentProfiles.firstMatch(segmentProfileList);

      final kilometreMap = parseKilometre(segmentProfile);

      final curvePoints = _parseCurvePoints(segmentProfile, segmentIndex, kilometreMap);
      final curveBeginPoints = curvePoints.where((curve) => curve.curvePointType == CurvePointType.begin);
      journeyData.addAll(curveBeginPoints);

      final signals = _parseSignals(segmentProfile, segmentIndex, kilometreMap);
      journeyData.addAll(signals);

      final newLineSpeeds = _parseNewLineSpeed(segmentProfile, segmentIndex, kilometreMap);

      final connectionTracks = _parseConnectionTrack(segmentProfile, segmentIndex, kilometreMap, newLineSpeeds);

      // Remove new line speeds that are already present as connection tracks
      newLineSpeeds.removeWhere((speedChange) =>
          connectionTracks.firstWhereOrNull((connectionTrack) => connectionTrack.speedData == speedChange.speedData) !=
          null);

      journeyData.addAll(connectionTracks);
      journeyData.addAll(newLineSpeeds);

      final balises = _parseBalise(segmentProfile, segmentIndex, kilometreMap);
      journeyData.addAll(balises);

      final whistles = _parseWhistle(segmentProfile, segmentIndex, kilometreMap);
      journeyData.addAll(whistles);

      final levelCrossings = _parseLevelCrossings(segmentProfile, segmentIndex, kilometreMap);
      journeyData.addAll(levelCrossings);

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
            speedData: _speedDataFromSpeeds(tafTapLocation.stationSpeed?.xmlStationSpeed.element)));
      }

      _parseAndAddProtectionSections(journeyData, segmentIndex, segmentProfile, kilometreMap);
    }

    final tramAreas = _parseTramAreas(segmentProfiles);
    journeyData.addAll(tramAreas);

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

    final trainCharacteristic = _resolveFirstTrainCharacteristics(journeyProfile, trainCharacteristics);
    final servicePoints = journeyData.where((it) => it.type == Datatype.servicePoint).toList();
    return Journey(
      metadata: Metadata(
        nextStop: servicePoints.length > 1 ? servicePoints[1] as ServicePoint : null,
        currentPosition: journeyData.first,
        additionalSpeedRestrictions: additionalSpeedRestrictions,
        routeStart: journeyData.firstOrNull,
        routeEnd: journeyData.lastOrNull,
        nonStandardTrackEquipmentSegments: trackEquipmentSegments,
        availableBreakSeries: _parseAvailableBreakSeries(journeyData),
        breakSeries: trainCharacteristic?.tcFeatures.trainCategoryCode != null &&
                trainCharacteristic?.tcFeatures.brakedWeightPercentage != null
            ? BreakSeries(
                trainSeries: trainCharacteristic!.tcFeatures.trainCategoryCode!,
                breakSeries: trainCharacteristic.tcFeatures.brakedWeightPercentage!)
            : null,
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
        final mainStationNsp =
            tafTapLocationNsp.parameters.where((it) => it.name == _bracketStationMainStationNspName).firstOrNull;
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
      final curveSpeed = curvePointNsp.xmlCurveSpeed?.element;
      return CurvePoint(
        order: calculateOrder(segmentIndex, curvePointNsp.location),
        kilometre: kilometreMap[curvePointNsp.location] ?? [],
        curvePointType: curvePointTypeValue != null ? CurvePointType.from(curvePointTypeValue) : null,
        curveType: curveTypeValue != null ? CurveType.from(curveTypeValue) : null,
        text: curveSpeed?.text,
        comment: curveSpeed?.comment,
        speedData: _speedDataFromSpeeds(curveSpeed?.speeds),
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

  static List<ConnectionTrack> _parseConnectionTrack(SegmentProfile segmentProfile, int segmentIndex,
      Map<double, List<double>> kilometreMap, List<SpeedChange> newLineSpeeds) {
    final connectionTracks = segmentProfile.contextInformation?.connectionTracks ?? [];
    return connectionTracks.map<ConnectionTrack>((connectionTrack) {
      final currentOrder = calculateOrder(segmentIndex, connectionTrack.location);
      final speedChange = newLineSpeeds.firstWhereOrNull((it) => it.order == currentOrder);
      return ConnectionTrack(
          text: connectionTrack.connectionTrackDescription,
          order: calculateOrder(segmentIndex, connectionTrack.location),
          speedData: speedChange?.speedData,
          kilometre: kilometreMap[connectionTrack.location] ?? []);
    }).toList();
  }

  static List<SpeedChange> _parseNewLineSpeed(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final newLineSpeeds = segmentProfile.points?.newLineSpeedsNsp ?? [];
    return newLineSpeeds.map<SpeedChange>((newLineSpeed) {
      return SpeedChange(
          text: newLineSpeed.xmlNewLineSpeed.element.text,
          speedData: _speedDataFromSpeeds(newLineSpeed.xmlNewLineSpeed.element.speeds),
          order: calculateOrder(segmentIndex, newLineSpeed.location),
          kilometre: kilometreMap[newLineSpeed.location] ?? []);
    }).toList();
  }

  static SpeedData? _speedDataFromSpeeds(Speeds? speeds) {
    if (speeds == null) return null;
    return SpeedData(
        velocities: speeds.velocities
            .map((it) => Velocity(
                trainSeries: it.trainSeries, reduced: it.reduced, speed: it.speed, breakSeries: it.brakeSeries))
            .toList());
  }

  static Set<BreakSeries> _parseAvailableBreakSeries(List<BaseData> journeyData) {
    return journeyData
        .where((it) => it.speedData != null)
        .map((it) => it.speedData!.velocities)
        .expand((it) => it)
        .where((it) => it.breakSeries != null)
        .map((it) => BreakSeries(trainSeries: it.trainSeries, breakSeries: it.breakSeries!))
        .toSet();
  }

  static TrainCharacteristics? _resolveFirstTrainCharacteristics(
      JourneyProfile journey, List<TrainCharacteristics> trainCharacteristics) {
    final firstTrainRef = journey.trainCharactericsRefSet.firstOrNull;
    if (firstTrainRef == null) return null;

    return trainCharacteristics.firstWhereOrNull((it) =>
        it.tcId == firstTrainRef.tcId &&
        it.ruId == firstTrainRef.ruId &&
        it.versionMajor == firstTrainRef.versionMajor &&
        it.versionMinor == firstTrainRef.versionMinor);
  }

  static Iterable<journey_balise.Balise> _parseBalise(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final balises = segmentProfile.points?.balise ?? [];
    return balises.map((balise) {
      return journey_balise.Balise(
        order: calculateOrder(segmentIndex, balise.location),
        kilometre: kilometreMap[balise.location] ?? [],
        amountLevelCrossings: balise.amountLevelCrossings,
      );
    });
  }

  static Iterable<Whistle> _parseWhistle(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final whistleNsps = segmentProfile.points?.whistleNsp ?? [];
    return whistleNsps.map((whistle) {
      return Whistle(
        order: calculateOrder(segmentIndex, whistle.location),
        kilometre: kilometreMap[whistle.location] ?? [],
      );
    });
  }

  static Iterable<LevelCrossing> _parseLevelCrossings(
      SegmentProfile segmentProfile, int segmentIndex, Map<double, List<double>> kilometreMap) {
    final levelCrossings = segmentProfile.contextInformation?.levelCrossings ?? [];
    return levelCrossings.map((levelCrossing) {
      return LevelCrossing(
        order: calculateOrder(segmentIndex, levelCrossing.startLocation),
        kilometre: kilometreMap[levelCrossing.startLocation] ?? [],
      );
    });
  }

  static List<TramArea> _parseTramAreas(List<SegmentProfile> segmentProfiles) {
    final List<TramArea> result = [];

    int? startSegmentIndex;
    int? endSegmentIndex;
    double? startLocation;
    double? endLocation;
    int? amountTramSignals;

    for (int segmentIndex = 0; segmentIndex < segmentProfiles.length; segmentIndex++) {
      final segmentProfile = segmentProfiles[segmentIndex];

      if (segmentProfile.areas == null) continue;

      for (final tramArea in segmentProfile.areas!.tramAreas) {
        switch (tramArea.startEndQualifier) {
          case StartEndQualifier.starts:
            startLocation = tramArea.startLocation;
            startSegmentIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            break;
          case StartEndQualifier.startsEnds:
            startLocation = tramArea.startLocation;
            startSegmentIndex = segmentIndex;
            amountTramSignals = tramArea.amountTramSignals?.amountTramSignals;
            continue next;
          next:
          case StartEndQualifier.ends:
            endLocation = tramArea.endLocation;
            endSegmentIndex = segmentIndex;
            break;
          case StartEndQualifier.wholeSp:
            break;
          case null:
            Fimber.w('Received tramArea with startEndQualifier=null');
            break;
        }

        if (startSegmentIndex != null &&
            endSegmentIndex != null &&
            startLocation != null &&
            endLocation != null &&
            amountTramSignals != null) {
          final startSegment = segmentProfiles[startSegmentIndex];
          final endSegment = segmentProfiles[endSegmentIndex];

          final startKilometreMap = parseKilometre(startSegment);
          final endKilometreMap = parseKilometre(endSegment);

          result.add(TramArea(
            order: calculateOrder(startSegmentIndex, startLocation),
            kilometre: startKilometreMap[startLocation]!,
            endKilometre: endKilometreMap[endLocation]!.first,
            amountTramSignals: amountTramSignals,
          ));

          startSegmentIndex = null;
          endSegmentIndex = null;
          startLocation = null;
          endLocation = null;
          amountTramSignals = null;
        }
      }
    }

    if (startSegmentIndex != null || endSegmentIndex != null || startLocation != null || endLocation != null) {
      Fimber.w('Incomplete tram area found: '
          'startSegmentIndex: $startSegmentIndex, endSegmentIndex: $endSegmentIndex, '
          'startLocation: $startLocation, endLocation: $endLocation, amountTramSignals: $amountTramSignals');
    }

    return result;
  }
}
