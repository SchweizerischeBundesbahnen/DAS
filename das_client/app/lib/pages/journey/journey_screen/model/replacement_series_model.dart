import 'package:app/pages/journey/journey_screen/model/illegal_speed_segment.dart';

sealed class ReplacementSeriesModel {
  const ReplacementSeriesModel._({
    required this.segment,
  });

  factory ReplacementSeriesModel.replacement({
    required IllegalSpeedSegment segment,
  }) = ReplacementSeriesAvailable;

  factory ReplacementSeriesModel.original({
    required IllegalSpeedSegment segment,
  }) = OriginalSeriesAvailable;

  factory ReplacementSeriesModel.selected({
    required IllegalSpeedSegment segment,
  }) = ReplacementSeriesSelected;

  factory ReplacementSeriesModel.none({
    required IllegalSpeedSegment segment,
  }) = NoReplacementSeries;

  final IllegalSpeedSegment segment;

  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType && other is ReplacementSeriesModel && segment == other.segment;

  @override
  int get hashCode => runtimeType.hashCode ^ segment.hashCode;
}

class ReplacementSeriesAvailable extends ReplacementSeriesModel {
  const ReplacementSeriesAvailable({required super.segment}) : super._();
}

class OriginalSeriesAvailable extends ReplacementSeriesModel {
  const OriginalSeriesAvailable({required super.segment}) : super._();
}

class ReplacementSeriesSelected extends ReplacementSeriesModel {
  const ReplacementSeriesSelected({required super.segment}) : super._();
}

class NoReplacementSeries extends ReplacementSeriesModel {
  const NoReplacementSeries({required super.segment}) : super._();
}
