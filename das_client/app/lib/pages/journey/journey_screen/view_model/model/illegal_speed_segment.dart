import 'package:sfera/component.dart';

class IllegalSpeedSegment({
  required final ServicePoint start,
  required final ServicePoint end,
  required final BrakeSeries original,
  final BrakeSeries? replacement,
}) {
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
