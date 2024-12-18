import 'package:das_client/model/journey/train_series.dart';

class BreakSeries {
  BreakSeries({
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
