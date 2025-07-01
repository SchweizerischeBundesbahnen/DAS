import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entity_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
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
      // ARRANGE
      final velocity = VelocityDto(attributes: {'trainSeries': 'A', 'speed': '50', 'reduced': 'false'});

      // ACT
      final result = SpeedMapper.fromVelocities([velocity]);

      // EXPECT
      expect(result, isNotEmpty);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.first.reduced, false);
    });

    test('fromVelocities_whenVelocityHasSpeedAndBrakeSeries_thenReturnTrainSeriesSpeedWithBrakeSeries', () {
      // ARRANGE
      final velocity = VelocityDto(
        attributes: {'trainSeries': 'A', 'brakeSeries': '1', 'speed': '50', 'reduced': 'false'},
      );

      // ACT
      final result = SpeedMapper.fromVelocities([velocity]);

      // EXPECT
      expect(result, isNotEmpty);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect(result?.first.breakSeries, 1);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.first.reduced, false);
    });

    test('fromVelocities_whenVelocityHasNoSpeed_thenReturnEmptyList', () {
      // ARRANGE
      final velocity = VelocityDto(attributes: {'trainSeries': 'A', 'reduced': 'false'});

      // ACT & EXPECT
      expect(SpeedMapper.fromVelocities([velocity]), isEmpty);
    });

    test(
      'fromGraduatedSpeedInfo_whenGraduatedSpeedInfoIsNull_thenReturnNull',
      () => expect(SpeedMapper.fromGraduatedSpeedInfo(null), isNull),
    );

    test('fromGraduatedSpeedInfo_whenGraduatedSpeedInfoHasEntities_thenReturnTrainSeriesSpeedList', () {
      // ARRANGE
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(
        children: [
          GraduatedSpeedInfoEntityDto(attributes: {'adSpeed': '50'}),
        ],
      );

      // ACT
      final result = SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo);

      // EXPECT
      expect(result, isNotEmpty);
      expect(result?.length, 2);
      expect(result?.first.trainSeries, TrainSeries.A);
      expect((result?.first.speed as SingleSpeed).value, '50');
      expect(result?.last.trainSeries, TrainSeries.D);
      expect((result?.last.speed as SingleSpeed).value, '50');
    });

    test('fromGraduatedSpeedInfo_whenEntityHasText_thenReturnTrainSeriesSpeedWithText', () {
      // ARRANGE
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(
        children: [
          GraduatedSpeedInfoEntityDto(attributes: {'adSpeed': '50', 'text': 'Some Text'}),
        ],
      );

      // ACT
      final result = SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo);

      // EXPECT
      expect(result, isNotEmpty);
      expect(result?.first.text, 'Some Text');
    });

    test('fromGraduatedSpeedInfo_whenEntityHasNoSpeed_thenReturnEmptyList', () {
      // ARRANGE
      final graduatedSpeedInfo = GraduatedSpeedInfoDto(children: [GraduatedSpeedInfoEntityDto()]);

      // ACT & EXPECT
      expect(SpeedMapper.fromGraduatedSpeedInfo(graduatedSpeedInfo), isEmpty);
    });

    test(
      'fromJourneyProfileContextInfoNsp_whenJpContextInfoNspIsNull_thenReturnNull',
      () => expect(SpeedMapper.fromJourneyProfileContextInfoNsp(null), isNull),
    );

    test(
      'fromJourneyProfileContextInfoNsp_whenParametersIsEmpty_thenReturnNull',
      () => expect(SpeedMapper.fromJourneyProfileContextInfoNsp(JpContextInformationNspDto(children: [])), isNull),
    );

    test('fromJourneyProfileContextInfoNsp_whenParameterIsNotNewSpeedNetworkSpecificParameterDto_thenReturnNull', () {
      // ARRANGE
      final jpContextInfoNsp = JpContextInformationNspDto(
        children: [JpContextInformationNspDto(type: 'SomeOtherType')],
      );

      // ACT & EXPECT
      expect(SpeedMapper.fromJourneyProfileContextInfoNsp(jpContextInfoNsp), isNull);
    });

    test(
      'fromJourneyProfileContextInfoNsp_whenParameterIsNewSpeedNetworkSpecificParameterDto_thenReturnSingleSpeed',
      () {
        // ARRANGE
        final jpContextInfoNsp = JpContextInformationNspDto(
          children: [
            NewSpeedNetworkSpecificParameterDto(attributes: {'name': 'newSpeed', 'value': '50'}),
          ],
        );

        // ACT
        final result = SpeedMapper.fromJourneyProfileContextInfoNsp(jpContextInfoNsp);

        // EXPECT
        expect(result, isNotNull);
        expect((result as SingleSpeed).value, '50');
      },
    );
  });
}
