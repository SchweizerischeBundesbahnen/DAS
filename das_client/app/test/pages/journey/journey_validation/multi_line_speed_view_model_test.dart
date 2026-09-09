import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_validation/journey_validation_view_model.dart';
import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/pages/journey/journey_validation/multi_line_speed_view_model.dart';
import 'package:app/pages/journey/view_model/model/resolved_train_series_speed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'multi_line_speed_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LineSpeedViewModel>(),
  MockSpec<JourneyValidationViewModel>(),
])
void main() {
  late MultiLineSpeedViewModel testee;
  late MockLineSpeedViewModel mockLineSpeedViewModel;
  late MockJourneyValidationViewModel mockJourneyValidationViewModel;

  const r120 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 120);
  const a100 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 100);

  final r120Speed = ResolvedTrainSeriesSpeed(
    speed: TrainSeriesSpeed(trainSeries: .R, brakedWeightPercentage: 120, speed: SingleSpeed(value: '105')),
    isPrevious: false,
  );
  final a100Speed = ResolvedTrainSeriesSpeed(
    speed: TrainSeriesSpeed(trainSeries: .A, brakedWeightPercentage: 100, speed: SingleSpeed(value: '100')),
    isPrevious: true,
  );

  setUp(() {
    mockLineSpeedViewModel = MockLineSpeedViewModel();
    mockJourneyValidationViewModel = MockJourneyValidationViewModel();

    testee = MultiLineSpeedViewModel(
      lineSpeedViewModel: mockLineSpeedViewModel,
      journeyValidationViewModel: mockJourneyValidationViewModel,
    );
  });

  test('test returns empty list when no brake series selected', () {
    when(mockJourneyValidationViewModel.brakeSeriesModelValue).thenReturn(MultiBrakeSeriesSelectionModel());

    expect(testee.getResolvedSpeedsForOrder(0), isEmpty);
    verifyNever(mockLineSpeedViewModel.getResolvedSpeedForOrder(any, brakeSeries: anyNamed('brakeSeries')));
  });

  test('test resolves speed for each selected brake series in order', () {
    when(mockJourneyValidationViewModel.brakeSeriesModelValue).thenReturn(
      MultiBrakeSeriesSelectionModel(selectedBrakeSeries: [r120, a100]),
    );
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(5, brakeSeries: r120)).thenReturn(r120Speed);
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(5, brakeSeries: a100)).thenReturn(a100Speed);

    expect(testee.getResolvedSpeedsForOrder(5), [r120Speed, a100Speed]);
  });
}
