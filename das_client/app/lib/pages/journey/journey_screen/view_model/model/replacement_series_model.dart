import 'package:app/pages/journey/journey_screen/view_model/model/illegal_speed_segment.dart';

sealed class const ReplacementSeriesModel._({
  required final IllegalSpeedSegment segment,
}) {
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

  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType && other is ReplacementSeriesModel && segment == other.segment;

  @override
  int get hashCode => runtimeType.hashCode ^ segment.hashCode;
}

class const ReplacementSeriesAvailable({required super.segment}) extends ReplacementSeriesModel {
  this : super._();
}

class const OriginalSeriesAvailable({required super.segment}) extends ReplacementSeriesModel {
  this : super._();
}

class const ReplacementSeriesSelected({required super.segment}) extends ReplacementSeriesModel {
  this : super._();
}

class const NoReplacementSeries({required super.segment}) extends ReplacementSeriesModel {
  this : super._();
}
