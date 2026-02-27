import 'dart:collection';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/illegal_speed_segment.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/replacement_series_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'replacement_series_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<JourneySettingsViewModel>(),
])
void main() {
  late ReplacementSeriesViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;
  late MockJourneySettingsViewModel mockJourneySettingsViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
  late BehaviorSubject<JourneySettings> journeySettingsSubject;

  final initialBrakeSeries = BrakeSeries(trainSeries: .N, brakeSeries: 180);
  final journey = Journey(
    metadata: Metadata(
      availableBrakeSeries: {
        initialBrakeSeries,
        BrakeSeries(trainSeries: .N, brakeSeries: 160),
        BrakeSeries(trainSeries: .R, brakeSeries: 120),
        BrakeSeries(trainSeries: .A, brakeSeries: 100),
        BrakeSeries(trainSeries: .D, brakeSeries: 100),
      },
      brakeSeries: initialBrakeSeries,
      lineSpeeds: SplayTreeMap.from({
        0: [
          TrainSeriesSpeed(
            trainSeries: .N,
            brakeSeries: 180,
            speed: SingleSpeed(value: '120'),
          ),
          TrainSeriesSpeed(
            trainSeries: .N,
            brakeSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
          TrainSeriesSpeed(
            trainSeries: .R,
            brakeSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        1: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 180,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 160,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            brakeSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        2: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 180,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            brakeSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        3: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 180,
            speed: SingleSpeed(value: '120'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            brakeSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            brakeSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            brakeSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
      }),
    ),
    data: [
      ServicePoint(name: 'A', abbreviation: '', locationCode: '', order: 0, kilometre: []),
      ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 1, kilometre: []),
      ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 2, kilometre: []),
      ServicePoint(name: 'D', abbreviation: '', locationCode: '', order: 3, kilometre: []),
      ServicePoint(name: 'E', abbreviation: '', locationCode: '', order: 4, kilometre: []),
      CurvePoint(
        order: 5,
        kilometre: [],
        localSpeeds: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            speed: SingleSpeed(value: 'XX'),
          ),
        ],
      ),
      ServicePoint(name: 'F', abbreviation: '', locationCode: '', order: 6, kilometre: []),
    ],
  );

  setUp(() {
    mockJourneyPositionViewModel = MockJourneyPositionViewModel();
    mockJourneyViewModel = MockJourneyViewModel();
    mockJourneySettingsViewModel = MockJourneySettingsViewModel();
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
    journeySettingsSubject = BehaviorSubject<JourneySettings>.seeded(
      JourneySettings(
        initialBrakeSeries: initialBrakeSeries,
      ),
    );
    when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockJourneyPositionViewModel.model).thenAnswer((_) => journeyPositionSubject.stream);
    when(mockJourneyPositionViewModel.modelValue).thenAnswer((_) => journeyPositionSubject.value);
    when(mockJourneySettingsViewModel.model).thenAnswer((_) => journeySettingsSubject.stream);
    when(mockJourneySettingsViewModel.modelValue).thenAnswer((_) => journeySettingsSubject.value);

    testee = ReplacementSeriesViewModel(
      journeyViewModel: mockJourneyViewModel,
      journeyPositionViewModel: mockJourneyPositionViewModel,
      journeySettingsViewModel: mockJourneySettingsViewModel,
    );
  });

  test('test provides correct replacement series', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test provides correct replacement series, selects series, returns orignal on end', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
        ReplacementSeriesSelected(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
        OriginalSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
      ),
    );

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[2] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[3] as JourneyPoint),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
      ),
    );

    testee.dispose();
  });

  test('test does not emit replacement, when none is found', () async {
    expectLater(
      testee.model,
      emitsInOrder([null]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.D, brakeSeries: 100),
      ),
    );

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test recalculates when switching to not suggested brakeSeries', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[2] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 160),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );
    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 160),
      ),
    );

    testee.dispose();
  });

  test('test notification disappears after reaching end of segment without user interaction', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[2] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[3] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test provides replacement series on invalid localSpeed', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[4] as ServicePoint,
            end: journey.data[6] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 180),
            replacement: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[4] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test emits no replacement when there is a illegal segment without replacement available', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        NoReplacementSeries(
          segment: IllegalSpeedSegment(
            start: journey.data[4] as ServicePoint,
            end: journey.data[6] as ServicePoint,
            original: BrakeSeries(trainSeries: TrainSeries.D, brakeSeries: 100),
            replacement: null,
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.D, brakeSeries: 100),
      ),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBrakeSeries: BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 120),
      ),
    );

    testee.dispose();
  });
}

Future<void> emitObjectToStream<T>(BehaviorSubject<T> subject, T object) async {
  subject.add(object);
  await Future.delayed(const Duration(milliseconds: 10));
}
