import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entries_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entry_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
import 'package:sfera/src/data/dto/vpro_data_nsp_dto.dart';
import 'package:sfera/src/data/mapper/speed_mapper.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/train_series.dart';

void main() {
  group('SpeedMapper', () {
    test(
      'fromVelocities_whenVelocitiesIsNull_thenReturnNull',
      () => expect(SpeedMapper.fromVelocities(null), isNull),
    );

    test(
      'fromVelocities_whenVelocitiesIsEmpty_thenReturnEmptyList',
      () => expect(SpeedMapper.fromVelocities([]), isEmpty),
    );

    test('fromVelocities_whenVelocityHasSpeed_thenReturnTrainSeriesSpeed', () {
      // GIVEN
      final velocity = VelocityDto(attributes: {'trainSeries': 'A', 'speed': '50', 'reduced': 'false'});

      // WHEN
      final result = SpeedMapper.fromVelocities([velocity]);

      // THEN
      expect(result, isNotEmpty);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.first.reduced, false);
    });

    test('fromVelocities_whenVelocityHasSpeedAndBrakeSeries_thenReturnTrainSeriesSpeedWithBrakeSeries', () {
      // GIVEN
      final velocity = VelocityDto(
        attributes: {'trainSeries': 'A', 'brakeSeries': '1', 'speed': '50', 'reduced': 'false'},
      );

      // WHEN
      final result = SpeedMapper.fromVelocities([velocity]);

      // THEN
      expect(result, isNotEmpty);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect(result?.first.brakedWeightPercentage, 1);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.first.reduced, false);
    });

    test('fromVelocities_whenVelocityHasNoSpeed_thenReturnEmptyList', () {
      // GIVEN
      final velocity = VelocityDto(attributes: {'trainSeries': 'A', 'reduced': 'false'});

      // WHEN & THEN
      expect(SpeedMapper.fromVelocities([velocity]), isEmpty);
    });

    test(
      'fromGraduatedSpeedInfo_whenGraduatedSpeedInfoIsNull_thenReturnNull',
      () => expect(SpeedMapper.fromGraduatedSpeedInfo(null), isNull),
    );

    test(
      'fromGraduatedSpeedInfo_whenGraduatedSpeedInfoHas---_thenIgnoresSpeed',
      () => expect(
        SpeedMapper.fromGraduatedSpeedInfo(
          GraduatedSpeedInfoDto(
            children: [
              GraduatedSpeedInfoEntriesDto(
                children: [
                  GraduatedSpeedInfoEntryDto(attributes: {'nSpeed': '---'}),
                ],
              ),
            ],
          ),
        ),
        isEmpty,
      ),
    );

    test('fromGraduatedSpeedInfo_whenGraduatedSpeedInfoHasEntities_thenReturnTrainSeriesSpeedList', () {
      // GIVEN
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(
        children: [
          GraduatedSpeedInfoEntriesDto(
            children: [
              GraduatedSpeedInfoEntryDto(attributes: {'adSpeed': '50'}),
            ],
          ),
        ],
      );

      // WHEN
      final result = SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo);

      // THEN
      expect(result, isNotEmpty);
      expect(result?.length, 2);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.last.trainSeries, TrainSeries.D);
      expect((result?.last.speed as SingleSpeed).value, '50');
    });

    test('fromGraduatedSpeedInfo_whenEntityHasText_thenReturnTrainSeriesSpeedWithText', () {
      // GIVEN
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(
        children: [
          GraduatedSpeedInfoEntriesDto(
            children: [
              GraduatedSpeedInfoEntryDto(attributes: {'adSpeed': '50', 'text': 'Some Text'}),
            ],
          ),
        ],
      );

      // WHEN
      final result = SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo);

      // THEN
      expect(result, isNotEmpty);
      expect(result?.first.text, 'Some Text');
    });

    test('fromGraduatedSpeedInfo_whenEntityHasNoSpeed_thenReturnEmptyList', () {
      // GIVEN
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(
        children: [
          GraduatedSpeedInfoEntriesDto(
            children: [GraduatedSpeedInfoEntryDto()],
          ),
        ],
      );

      // WHEN & THEN
      expect(SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo), isEmpty);
    });

    test(
      'fromVProDataNsp_whenJpContextInfoNspIsNull_thenReturnNull',
      () => expect(SpeedMapper.fromVProDataNsp(null), isNull),
    );

    test(
      'fromVProDataNsp_whenParametersIsEmpty_thenReturnNull',
      () => expect(SpeedMapper.fromVProDataNsp(VProDataNspDto(children: [])), isNull),
    );

    test('fromVProDataNsp_whenParameterIsNotNewSpeedNetworkSpecificParameterDto_thenReturnNull', () {
      // GIVEN
      final vProDataNsp = VProDataNspDto(
        children: [JpContextInformationNspDto(type: 'SomeOtherType')],
      );

      // WHEN & THEN
      expect(SpeedMapper.fromVProDataNsp(vProDataNsp), isNull);
    });

    test(
      'fromJourneyProfileContextInfoNsp_whenParameterIsNewSpeedNetworkSpecificParameterDto_thenReturnSingleSpeed',
      () {
        // GIVEN
        final vProDataNsp = VProDataNspDto(
          children: [
            NewSpeedNetworkSpecificParameterDto(attributes: {'name': 'newSpeed', 'value': '50'}),
          ],
        );

        // WHEN
        final result = SpeedMapper.fromVProDataNsp(vProDataNsp);

        // THEN
        expect(result, isNotNull);
        expect((result as SingleSpeed).value, '50');
      },
    );
  });
}
