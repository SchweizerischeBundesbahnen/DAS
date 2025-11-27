import 'package:collection/collection.dart';

enum TrainSeries {
  A,
  R,
  N,
  D,
  O,
  W,
  S
  ;

  factory TrainSeries.from(String value) => values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
  );

  static TrainSeries? fromOptional(String? value) => values.firstWhereOrNull(
    (e) => e.name.toLowerCase() == value?.toLowerCase(),
  );

  bool canReplace(TrainSeries other) {
    if (this == other) return true;
    if (this == .R && other == .N) return true;
    if (this == .A && other == .N) return true;
    if (this == .A && other == .R) return true;
    return false;
  }
}
