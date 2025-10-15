import 'package:sfera/component.dart';

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
