import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/enums/gradient_direction_type_dto.dart';
import 'package:sfera/src/data/dto/enums/length_type_dto.dart';
import 'package:sfera/src/data/dto/enums/stop_skip_pass_dto.dart';
import 'package:sfera/src/data/dto/enums/taf_tap_location_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/foot_note_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_content_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_title_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/station_property_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/timing_point_constraints_dto.dart';
import 'package:sfera/src/data/mapper/mapper_utils.dart';
import 'package:sfera/src/data/mapper/speed_mapper.dart';
import 'package:sfera/src/model/journey/bracket_station.dart';
import 'package:sfera/src/model/journey/decisive_gradient.dart';

class _MapperData {
  _MapperData(this.segmentProfile, this.segmentIndex, this.kilometreMap);

  final SegmentProfileDto segmentProfile;
  final int segmentIndex;
  final KilometreMap kilometreMap;
}

final _log = Logger('SegmentProfileMapper');

class SegmentProfileMapper {
  SegmentProfileMapper._();

  static const String _bracketStationNspName = 'bracketStation';
  static const String _bracketStationMainStationNspName = 'mainStation';
  static const String _bracketStationTextNspName = 'text';
  static const String _protectionSectionNspFacultativeName = 'facultative';
  static const String _protectionSectionNspLengthTypeName = 'lengthType';

  static List<BaseData> parseSegmentProfile(
    SegmentProfileReferenceDto segmentProfileReference,
    int segmentIndex,
    List<SegmentProfileDto> segmentProfiles,
  ) {
    final segmentProfile = segmentProfiles.firstMatch(segmentProfileReference);
    final kilometreMap = parseKilometre(segmentProfile);
    final mapperData = _MapperData(segmentProfile, segmentIndex, kilometreMap);

    final journeyData = <BaseData>[];
    journeyData.addAll(_parseSignals(mapperData));
    journeyData.addAll(_parseBalise(mapperData));
    journeyData.addAll(_parseWhistle(mapperData));
    journeyData.addAll(_parseLevelCrossings(mapperData));
    journeyData.addAll(_parseProtectionSections(mapperData));
    journeyData.addAll(_parseOpFootNotes(mapperData));
    journeyData.addAll(_parseLineFootNotes(mapperData));
    journeyData.addAll(_parseTrackFootNotes(mapperData));
    journeyData.addAll(_parseServicePoint(mapperData, segmentProfiles, segmentProfileReference));

    final curvePoints = _parseCurvePoints(mapperData);
    journeyData.addAll(curvePoints);

    final newLineSpeeds = _parseNewLineSpeed(mapperData);
    final connectionTracks = _parseConnectionTrack(mapperData, newLineSpeeds);

    newLineSpeeds.removeWhere(
      (speedChange) =>
          connectionTracks.firstWhereOrNull((connectionTrack) => connectionTrack.order == speedChange.order) != null,
    );

    journeyData.addAll(connectionTracks);
    journeyData.addAll(newLineSpeeds);

    return journeyData;
  }

  static SplayTreeMap<int, Iterable<TrainSeriesSpeed>> parseLineSpeeds(List<SegmentProfileDto> segmentProfiles) {
    final result = SplayTreeMap<int, Iterable<TrainSeriesSpeed>>();

    segmentProfiles.forEachIndexed((index, segmentProfile) {
      final tafTapLocations = segmentProfile.areas?.tafTapLocations ?? [];

      for (final location in tafTapLocations) {
        final speeds = SpeedMapper.fromVelocities(location.newLineSpeed?.xmlNewLineSpeed.element.velocities);

        if (speeds != null) {
          result[calculateOrder(index, location.startLocation!)] = speeds;
        }
      }

      final newLineSpeeds = segmentProfile.points?.newLineSpeedsNsp ?? [];
      for (final newLineSpeed in newLineSpeeds) {
        final velocities = newLineSpeed.xmlNewLineSpeed.element.speeds?.velocities;
        final speed = SpeedMapper.fromVelocities(velocities);
        if (speed != null) {
          result[calculateOrder(index, newLineSpeed.location)] = speed;
        }
      }
    });

    return result;
  }

  static List<ServicePoint> _parseServicePoint(
    _MapperData mapperData,
    List<SegmentProfileDto> segmentProfiles,
    SegmentProfileReferenceDto segmentProfileReference,
  ) {
    final servicePoints = <ServicePoint>[];

    final timingPoints = mapperData.segmentProfile.points?.timingPoints.toList() ?? [];
    final tafTapLocations = segmentProfiles.map((it) => it.areas).nonNulls.expand((it) => it.tafTapLocations).toList();

    for (final tpConstraint in segmentProfileReference.timingPointsConstraints) {
      final tpId = tpConstraint.timingPointReference.tpIdReference.tpId;
      final timingPoint = timingPoints.where((it) => it.id == tpId).first;
      final tafTapLocation = tafTapLocations.firstWhereGiven(
        countryCode: timingPoint.locationReference?.countryCodeISO,
        primaryCode: timingPoint.locationReference?.locationPrimaryCode,
      );

      servicePoints.add(
        ServicePoint(
          name: tafTapLocation.locationIdent.primaryLocationName?.value ?? '',
          order: calculateOrder(mapperData.segmentIndex, timingPoint.location),
          mandatoryStop: tpConstraint.stoppingPointInformation?.stopType?.mandatoryStop ?? true,
          isStop: tpConstraint.stopSkipPass == StopSkipPassDto.stoppingPoint,
          isStation: tafTapLocation.locationType != TafTapLocationTypeDto.halt,
          isAdditional: tafTapLocation.routeTableDataNsp?.routeTableDataRelevant?.isAdditional ?? false,
          betweenBrackets: tafTapLocation.routeTableDataNsp?.betweenBrackets ?? false,
          bracketMainStation: _parseBracketMainStation(tafTapLocations, tafTapLocation),
          kilometre: mapperData.kilometreMap[timingPoint.location] ?? [],
          localSpeeds: SpeedMapper.fromVelocities(
            tafTapLocation.stationSpeed?.xmlStationSpeed?.element.velocities,
          ),
          graduatedSpeedInfo: SpeedMapper.fromGraduatedSpeedInfo(
            tafTapLocation.stationSpeed?.xmlGraduatedSpeedInfo?.element,
          ),
          decisiveGradient: _parseDecisiveGradientAtLocation(mapperData.segmentProfile, timingPoint.location),
          arrivalDepartureTime: _parseArrivalDepartureTime(tpConstraint),
          stationSign1: tafTapLocation.routeTableDataNsp?.stationSign1,
          stationSign2: tafTapLocation.routeTableDataNsp?.stationSign2,
          properties: _parseStationProperties(tafTapLocation.property?.xmlStationProperty.element.properties),
          localRegulationSections: _parseLocalRegulationSegments(tafTapLocation.localRegulations),
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

  static List<ProtectionSection> _parseProtectionSections(_MapperData mapperData) {
    final currentLimitation = mapperData.segmentProfile.characteristics?.currentLimitation;
    if (currentLimitation == null) return List.empty();

    final protectionSections = <ProtectionSection>[];
    final protectionSectionNsps = mapperData.segmentProfile.points?.protectionSectionNsp ?? [];
    for (final currentLimitationChange in currentLimitation.currentLimitationChanges) {
      if (currentLimitationChange.maxCurValue == '0') {
        final protectionSectionNsp = protectionSectionNsps
            .where((it) => it.location == currentLimitationChange.location)
            .firstOrNull;

        final isOptional = protectionSectionNsp?.parameters.withName(_protectionSectionNspFacultativeName);
        final isLong = protectionSectionNsp?.parameters.withName(_protectionSectionNspLengthTypeName);

        protectionSections.add(
          ProtectionSection(
            isOptional: isOptional != null ? bool.parse(isOptional.nspValue) : false,
            isLong: isLong != null
                ? XmlEnum.valueOf(LengthTypeDto.values, isLong.nspValue) == LengthTypeDto.long
                : false,
            order: calculateOrder(mapperData.segmentIndex, currentLimitationChange.location),
            kilometre: mapperData.kilometreMap[currentLimitationChange.location]!,
          ),
        );
      }
    }
    return protectionSections;
  }

  static BracketMainStation? _parseBracketMainStation(
    List<TafTapLocationDto> allLocations,
    TafTapLocationDto tafTapLocation,
  ) {
    for (final tafTapLocationNsp in tafTapLocation.nsp) {
      if (tafTapLocationNsp.groupName == _bracketStationNspName) {
        final mainStationNsp = tafTapLocationNsp.parameters.withName(_bracketStationMainStationNspName);
        final textNsp = tafTapLocationNsp.parameters.withName(_bracketStationTextNspName);
        if (mainStationNsp == null) {
          _log.warning('Encountered bracket station without main station NSP declaration: $tafTapLocation');
        } else {
          final countryCode = mainStationNsp.nspValue.substring(0, 2);
          final primaryCode = int.parse(mainStationNsp.nspValue.substring(2, 6));
          final mainStation = allLocations.firstWhereGivenOrNull(countryCode: countryCode, primaryCode: primaryCode);
          if (mainStation == null) {
            _log.warning('Failed to resolve main station for bracket station: $tafTapLocation');
          }

          return BracketMainStation(
            abbreviation: textNsp?.nspValue ?? '',
            countryCode: countryCode,
            primaryCode: primaryCode,
          );
        }
      }
    }

    return null;
  }

  static List<CurvePoint> _parseCurvePoints(_MapperData mapperData) {
    final raw = mapperData.segmentProfile.points?.curvePointsNsp ?? [];
    final points = raw
        .map<CurvePoint>((curvePointNsp) {
          final curveSpeed = curvePointNsp.xmlCurveSpeed?.element;
          return CurvePoint(
            order: calculateOrder(mapperData.segmentIndex, curvePointNsp.location),
            kilometre: mapperData.kilometreMap[curvePointNsp.location] ?? [],
            curvePointType: curvePointNsp.curvePointType != null
                ? CurvePointType.from(curvePointNsp.curvePointType!)
                : null,
            curveType: curvePointNsp.curveType != null ? CurveType.from(curvePointNsp.curveType!) : null,
            text: curveSpeed?.text,
            comment: curveSpeed?.comment,
            localSpeeds: SpeedMapper.fromVelocities(curveSpeed?.speeds?.velocities),
          );
        })
        .sortedBy((p) => p.order)
        .toList();

    final summarized = <CurvePoint>[];
    CurvePoint? temporary;

    for (final point in points) {
      if (point.curvePointType == CurvePointType.begin) {
        temporary = point;
        continue;
      }
      if (point.curvePointType == CurvePointType.end && temporary != null) {
        final startKm = temporary.kilometre.firstOrNull;
        final endKm = point.kilometre.firstOrNull;
        summarized.add(
          CurvePoint(
            order: temporary.order,
            kilometre: [
              if (startKm != null) startKm,
              if (endKm != null) endKm,
            ],
            localSpeeds: temporary.localSpeeds,
            curvePointType: CurvePointType.summarized,
            curveType: temporary.curveType,
            text: temporary.text,
            comment: temporary.comment,
          ),
        );
        temporary = null;
      }
    }

    return summarized;
  }

  static List<ConnectionTrack> _parseConnectionTrack(_MapperData mapperData, List<SpeedChange> newLineSpeeds) {
    final connectionTracks = mapperData.segmentProfile.contextInformation?.connectionTracks ?? [];
    return connectionTracks.map<ConnectionTrack>((connectionTrack) {
      return ConnectionTrack(
        text: connectionTrack.connectionTrackDescription?.text,
        order: calculateOrder(mapperData.segmentIndex, connectionTrack.location),
        kilometre: mapperData.kilometreMap[connectionTrack.location] ?? [],
      );
    }).toList();
  }

  static List<SpeedChange> _parseNewLineSpeed(_MapperData mapperData) {
    final newLineSpeeds = mapperData.segmentProfile.points?.newLineSpeedsNsp ?? [];
    return newLineSpeeds.map<SpeedChange>((newLineSpeed) {
      return SpeedChange(
        text: newLineSpeed.xmlNewLineSpeed.element.text,
        order: calculateOrder(mapperData.segmentIndex, newLineSpeed.location),
        kilometre: mapperData.kilometreMap[newLineSpeed.location] ?? [],
      );
    }).toList();
  }

  static Iterable<Balise> _parseBalise(_MapperData mapperData) {
    final balises = mapperData.segmentProfile.points?.balises ?? [];
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

  static Iterable<TrackFootNote> _parseTrackFootNotes(_MapperData mapperData) {
    final trackFootNotesNsp = mapperData.segmentProfile.points?.trackFootNotesNsp ?? [];
    return trackFootNotesNsp.map((trackFootNoteNsp) {
      final footNotes = _parseFootNotes(trackFootNoteNsp.xmlTrackFootNotes.element.footNotes);
      return footNotes.map(
        (note) => TrackFootNote(
          order: calculateOrder(mapperData.segmentIndex, trackFootNoteNsp.location),
          footNote: note,
        ),
      );
    }).flattenedToList;
  }

  static Iterable<OpFootNote> _parseOpFootNotes(_MapperData mapperData) {
    final locations = mapperData.segmentProfile.areas?.tafTapLocations ?? [];
    return locations
        .map((location) {
          if (location.opFootNotes == null) {
            return null;
          }

          if (location.startLocation == null) {
            _log.warning('Failed to parse opFootNote because TafTapLocation has no startLocation: $location');
            return null;
          }

          final footNotes = _parseFootNotes(location.opFootNotes!.xmlOpFootNotes.element.footNotes);
          return footNotes.map(
            (note) => OpFootNote(
              order: calculateOrder(mapperData.segmentIndex, location.startLocation!),
              footNote: note,
            ),
          );
        })
        .nonNulls
        .flattenedToList
        .nonNulls;
  }

  static Iterable<LineFootNote> _parseLineFootNotes(_MapperData mapperData) {
    final locations = mapperData.segmentProfile.areas?.tafTapLocations ?? [];
    return locations
        .map((location) {
          if (location.lineFootNotes == null) {
            return null;
          }

          if (location.startLocation == null) {
            _log.warning('Failed to parse lineFootNote because TafTapLocation has no startLocation: $location');
            return null;
          }

          final footNotes = _parseFootNotes(location.lineFootNotes!.xmlLineFootNotes.element.footNotes);
          return footNotes.map(
            (note) => LineFootNote(
              locationName: location.locationIdent.primaryLocationName?.value ?? '',
              order: calculateOrder(mapperData.segmentIndex, location.startLocation!),
              footNote: note,
            ),
          );
        })
        .nonNulls
        .flattenedToList
        .nonNulls;
  }

  static List<FootNote> _parseFootNotes(Iterable<SferaFootNoteDto> footNotes) {
    return footNotes.map((note) {
      return FootNote(
        text: note.text,
        type: note.footNoteType?.footNoteType,
        refText: note.refText,
        identifier: note.identifier,
        trainSeries: _parseTrainSeries(note.trainSeries),
      );
    }).toList();
  }

  static List<TrainSeries> _parseTrainSeries(String? trainSeries) {
    return trainSeries?.split(',').map((it) => TrainSeries.fromOptional(it)).nonNulls.toList() ?? [];
  }

  static DecisiveGradient? _parseDecisiveGradientAtLocation(SegmentProfileDto segmentProfile, double location) {
    final decisiveGradientAreas = segmentProfile.contextInformation?.decisiveGradientAreas.where(
      (it) => it.startLocation == location,
    );
    if (decisiveGradientAreas == null || decisiveGradientAreas.isEmpty) {
      return null;
    }

    double? uphill, downhill;
    for (final gradientArea in decisiveGradientAreas) {
      if (gradientArea.gradientDirectionType == GradientDirectionTypeDto.uphill) {
        uphill = gradientArea.gradientValue;
      } else {
        downhill = gradientArea.gradientValue;
      }
    }

    return DecisiveGradient(uphill: uphill, downhill: downhill);
  }

  static ArrivalDepartureTime? _parseArrivalDepartureTime(TimingPointConstraintsDto timingPointConstraint) {
    final departureDetails = timingPointConstraint.stoppingPointDepartureDetails;
    final operationalArrivalTime = timingPointConstraint.latestArrivalTime;
    final plannedArrivalTime = timingPointConstraint.plannedLatestArrivalTime;
    if (departureDetails == null && operationalArrivalTime == null && plannedArrivalTime == null) return null;

    return ArrivalDepartureTime(
      ambiguousDepartureTime: departureDetails?.departureTime,
      plannedDepartureTime: departureDetails?.plannedDepartureTime,
      ambiguousArrivalTime: operationalArrivalTime,
      plannedArrivalTime: plannedArrivalTime,
    );
  }

  static List<StationProperty> _parseStationProperties(Iterable<StationPropertyDto>? properties) {
    if (properties == null || properties.isEmpty) {
      return [];
    }

    return properties.map((property) {
      return StationProperty(
        text: property.text,
        sign: StationSign.fromOptional(property.sign),
        speeds: SpeedMapper.fromVelocities(property.speeds?.velocities),
      );
    }).toList();
  }

  static List<LocalRegulationSection> _parseLocalRegulationSegments(Iterable<LocalRegulationNspDto> localRegulations) {
    return localRegulations.map((dto) {
      return LocalRegulationSection(
        title: dto.titles.toLocalizedString,
        content: dto.contents.toLocalizedString,
      );
    }).toList();
  }
}
