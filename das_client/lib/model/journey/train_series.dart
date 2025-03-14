import 'package:collection/collection.dart';

enum TrainSeries {
  A,
  D,
  N,
  O,
  R,
  W,
  S;

  factory TrainSeries.from(String value) => values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );

  static TrainSeries? fromOptional(String? value) => values.firstWhereOrNull(
        (e) => e.name.toLowerCase() == value?.toLowerCase(),
      );
}
