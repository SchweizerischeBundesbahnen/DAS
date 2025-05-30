import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class BreakSeries {
  const BreakSeries({
    required this.trainSeries,
    required this.breakSeries,
  });

  final TrainSeries trainSeries;
  final int breakSeries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakSeries &&
          runtimeType == other.runtimeType &&
          trainSeries == other.trainSeries &&
          breakSeries == other.breakSeries;

  @override
  int get hashCode => trainSeries.hashCode ^ breakSeries.hashCode;

  @override
  String toString() {
    return '${trainSeries.name}$breakSeries';
  }
}
