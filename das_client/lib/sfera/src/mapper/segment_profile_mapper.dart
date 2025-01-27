import 'package:collection/collection.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:das_client/sfera/src/mapper/graduated_speed_data_mapper.dart';
import 'package:das_client/sfera/src/mapper/mapper_utils.dart';
import 'package:das_client/sfera/src/model/enums/length_type.dart';
import 'package:das_client/sfera/src/model/enums/stop_skip_pass.dart';
import 'package:das_client/sfera/src/model/enums/taf_tap_location_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/multilingual_text.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile_list.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';
import 'package:fimber/fimber.dart';

class _MapperData {
  _MapperData(this.segmentProfile, this.segmentIndex, this.kilometreMap);

  final SegmentProfile segmentProfile;
  final int segmentIndex;
  final KilometreMap kilometreMap;
}

/// Used to map journey data from a SFERA segment profile.
class SegmentProfileMapper {
  SegmentProfileMapper._();

  static const String _bracketStationNspName = 'bracketStation';
  static const String _bracketStationMainStationNspName = 'mainStation';
  static const String _bracketStationTextNspName = 'text';
  static const String _protectionSectionNspFacultativeName = 'facultative';
  static const String _protectionSectionNspLengthTypeName = 'lengthType';

  static List<BaseData> parseSegmentProfile(
      SegmentProfileList segmentProfileList, int segmentIndex, List<SegmentProfile> segmentProfiles) {
    final segmentProfile = segmentProfiles.firstMatch(segmentProfileList);
    final kilometreMap = parseKilometre(segmentProfile);
    final mapperData = _MapperData(segmentProfile, segmentIndex, kilometreMap);

    final journeyData = <BaseData>[];
    journeyData.addAll(_parseSignals(mapperData));
    journeyData.addAll(_parseBalise(mapperData));
    journeyData.addAll(_parseWhistle(mapperData));
    journeyData.addAll(_parseLevelCrossings(mapperData));
    journeyData.addAll(_parseProtectionSections(mapperData));
    journeyData.addAll(_parseServicePoint(mapperData, segmentProfiles, segmentProfileList));

    final curvePoints = _parseCurvePoints(mapperData);
    final curveBeginPoints = curvePoints.where((curve) => curve.curvePointType == CurvePointType.begin);
    journeyData.addAll(curveBeginPoints);

    final newLineSpeeds = _parseNewLineSpeed(mapperData);
    final connectionTracks = _parseConnectionTrack(mapperData, newLineSpeeds);

    // Remove new line speeds that are already present as connection tracks
    newLineSpeeds.removeWhere((speedChange) =>
        connectionTracks.firstWhereOrNull((connectionTrack) => connectionTrack.speedData == speedChange.speedData) !=
        null);

    journeyData.addAll(connectionTracks);
    journeyData.addAll(newLineSpeeds);

    return journeyData;
  }

  static List<ServicePoint> _parseServicePoint(
      _MapperData mapperData, List<SegmentProfile> segmentProfiles, SegmentProfileList segmentProfileList) {
    final servicePoints = <ServicePoint>[];

    final timingPoints = mapperData.segmentProfile.points?.timingPoints.toList() ?? [];
    final tafTapLocations = segmentProfiles.map((it) => it.areas).nonNulls.expand((it) => it.tafTapLocations).toList();

    for (final tpConstraint in segmentProfileList.timingPointsContraints) {
      final tpId = tpConstraint.timingPointReference.tpIdReference.tpId;
      final timingPoint = timingPoints.where((it) => it.id == tpId).first;
      final tafTapLocation = tafTapLocations
          .where((it) =>
              it.locationIdent.countryCodeISO == timingPoint.locationReference?.countryCodeISO &&
              it.locationIdent.locationPrimaryCode == timingPoint.locationReference?.locationPrimaryCode)
          .first;

      servicePoints.add(
        ServicePoint(
          name: _localizedStringFromMultilingualText(tafTapLocation.locationNames),
          order: calculateOrder(mapperData.segmentIndex, timingPoint.location),
          mandatoryStop: tpConstraint.stoppingPointInformation?.stopType?.mandatoryStop ?? true,
          isStop: tpConstraint.stopSkipPass == StopSkipPass.stoppingPoint,
          isStation: tafTapLocation.locationType != TafTapLocationType.halt,
          bracketMainStation: _parseBracketMainStation(tafTapLocations, tafTapLocation),
          kilometre: mapperData.kilometreMap[timingPoint.location] ?? [],
          speedData:
              GraduatedSpeedDataMapper.fromVelocities(tafTapLocation.newLineSpeed?.xmlNewLineSpeed.element.velocities),
          localSpeedData:
              GraduatedSpeedDataMapper.fromVelocities(tafTapLocation.stationSpeed?.xmlStationSpeed.element.velocities),
          graduatedSpeedInfo: GraduatedSpeedDataMapper.fromGraduatedSpeedInfo(
              tafTapLocation.stationSpeed?.xmlGraduatedSpeedInfo?.element),
        ),
      );
    }

    return servicePoints;
  }

  static Iterable<Signal> _parseSignals(_MapperData mapperData) {
    final signals = mapperData.segmentProfile.points?.signals ?? [];
    return signals.map((signal) {
      return Signal(
        visualIdentifier: signal.physicalCharacteristics?.visualIdentifier,
        functions: signal.functions.map((function) => SignalFunction.from(function.value!)).toList(),
        order: calculateOrder(mapperData.segmentIndex, signal.id.location),
        kilometre: mapperData.kilometreMap[signal.id.location] ?? [],
      );
    });
  }

  static LocalizedString _localizedStringFromMultilingualText(Iterable<MultilingualText> multilingualText) {
    return LocalizedString(
      de: multilingualText.messageFor('de'),
      fr: multilingualText.messageFor('fr'),
      it: multilingualText.messageFor('it'),
    );
  }

  static List<ProtectionSection> _parseProtectionSections(_MapperData mapperData) {
    final protectionSections = <ProtectionSection>[];
    final currentLimitation = mapperData.segmentProfile.characteristics?.currentLimitation;
    if (currentLimitation != null) {
      final protectionSectionNsps = mapperData.segmentProfile.points?.protectionSectionNsp ?? [];

      for (final currentLimitationChange in currentLimitation.currentLimitationChanges) {
        if (currentLimitationChange.maxCurValue == '0') {
          final protectionSectionNsp =
              protectionSectionNsps.where((it) => it.location == currentLimitationChange.location).firstOrNull;

          final isOptional = protectionSectionNsp?.parameters.withName(_protectionSectionNspFacultativeName);
          final isLong = protectionSectionNsp?.parameters.withName(_protectionSectionNspLengthTypeName);

          protectionSections.add(ProtectionSection(
              isOptional: isOptional != null ? bool.parse(isOptional.nspValue) : false,
              isLong: isLong != null ? XmlEnum.valueOf(LengthType.values, isLong.nspValue) == LengthType.long : false,
              order: calculateOrder(mapperData.segmentIndex, currentLimitationChange.location),
              kilometre: mapperData.kilometreMap[currentLimitationChange.location]!));
        }
      }
    }
    return protectionSections;
  }

  static BracketMainStation? _parseBracketMainStation(
      List<TafTapLocation> allLocations, TafTapLocation tafTapLocation) {
    for (final tafTapLocationNsp in tafTapLocation.nsp) {
      if (tafTapLocationNsp.name == _bracketStationNspName) {
        final mainStationNsp = tafTapLocationNsp.parameters.withName(_bracketStationMainStationNspName);
        final textNsp = tafTapLocationNsp.parameters.withName(_bracketStationTextNspName);
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
          }

          return BracketMainStation(
              abbreviation: textNsp?.nspValue ?? '', countryCode: countryCode, primaryCode: primaryCode);
        }
      }
    }

    return null;
  }

  static List<CurvePoint> _parseCurvePoints(_MapperData mapperData) {
    final curvePointsNsp = mapperData.segmentProfile.points?.curvePointsNsp ?? [];
    return curvePointsNsp.map<CurvePoint>((curvePointNsp) {
      final curvePointTypeValue = curvePointNsp.parameters.withName('curvePointType')?.nspValue;
      final curveTypeValue = curvePointNsp.parameters.withName('curveType')?.nspValue;
      final curveSpeed = curvePointNsp.xmlCurveSpeed?.element;
      return CurvePoint(
        order: calculateOrder(mapperData.segmentIndex, curvePointNsp.location),
        kilometre: mapperData.kilometreMap[curvePointNsp.location] ?? [],
        curvePointType: curvePointTypeValue != null ? CurvePointType.from(curvePointTypeValue) : null,
        curveType: curveTypeValue != null ? CurveType.from(curveTypeValue) : null,
        text: curveSpeed?.text,
        comment: curveSpeed?.comment,
        localSpeedData: GraduatedSpeedDataMapper.fromVelocities(curveSpeed?.speeds?.velocities),
      );
    }).toList();
  }

  static List<ConnectionTrack> _parseConnectionTrack(_MapperData mapperData, List<SpeedChange> newLineSpeeds) {
    final connectionTracks = mapperData.segmentProfile.contextInformation?.connectionTracks ?? [];
    return connectionTracks.map<ConnectionTrack>((connectionTrack) {
      final currentOrder = calculateOrder(mapperData.segmentIndex, connectionTrack.location);
      final speedChange = newLineSpeeds.firstWhereOrNull((it) => it.order == currentOrder);
      return ConnectionTrack(
          text: connectionTrack.connectionTrackDescription,
          order: calculateOrder(mapperData.segmentIndex, connectionTrack.location),
          speedData: speedChange?.speedData,
          kilometre: mapperData.kilometreMap[connectionTrack.location] ?? []);
    }).toList();
  }

  static List<SpeedChange> _parseNewLineSpeed(_MapperData mapperData) {
    final newLineSpeeds = mapperData.segmentProfile.points?.newLineSpeedsNsp ?? [];
    return newLineSpeeds.map<SpeedChange>((newLineSpeed) {
      final velocities = newLineSpeed.xmlNewLineSpeed.element.speeds?.velocities;
      return SpeedChange(
          text: newLineSpeed.xmlNewLineSpeed.element.text,
          speedData: GraduatedSpeedDataMapper.fromVelocities(velocities),
          order: calculateOrder(mapperData.segmentIndex, newLineSpeed.location),
          kilometre: mapperData.kilometreMap[newLineSpeed.location] ?? []);
    }).toList();
  }

  static Iterable<Balise> _parseBalise(_MapperData mapperData) {
    final balises = mapperData.segmentProfile.points?.balise ?? [];
    return balises.map((balise) {
      return Balise(
        order: calculateOrder(mapperData.segmentIndex, balise.location),
        kilometre: mapperData.kilometreMap[balise.location] ?? [],
        amountLevelCrossings: balise.amountLevelCrossings,
      );
    });
  }

  static Iterable<Whistle> _parseWhistle(_MapperData mapperData) {
    final whistleNsps = mapperData.segmentProfile.points?.whistleNsp ?? [];
    return whistleNsps.map((whistle) {
      return Whistle(
        order: calculateOrder(mapperData.segmentIndex, whistle.location),
        kilometre: mapperData.kilometreMap[whistle.location] ?? [],
      );
    });
  }

  static Iterable<LevelCrossing> _parseLevelCrossings(_MapperData mapperData) {
    final levelCrossings = mapperData.segmentProfile.contextInformation?.levelCrossings ?? [];
    return levelCrossings.map((levelCrossing) {
      return LevelCrossing(
        order: calculateOrder(mapperData.segmentIndex, levelCrossing.startLocation),
        kilometre: mapperData.kilometreMap[levelCrossing.startLocation] ?? [],
      );
    });
  }
}
