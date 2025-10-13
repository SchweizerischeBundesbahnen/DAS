import 'package:sfera/component.dart';

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

class IllegalSpeedSegment {
  IllegalSpeedSegment({
    required this.start,
    required this.end,
    required this.original,
    this.replacement,
  });

  final ServicePoint start;
  final ServicePoint end;
  final BreakSeries original;
  final BreakSeries? replacement;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IllegalSpeedSegment &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          original == other.original &&
          replacement == other.replacement;

  @override
  int get hashCode => Object.hash(start, end, original, replacement);
}
