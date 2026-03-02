import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class BrakeSeries {
  const BrakeSeries({
    required this.trainSeries,
    required this.brakeSeries,
  });

  final TrainSeries trainSeries;
  final int brakeSeries;

  /// returns train series name + brake series number (ie. R150)
  String get name => '${trainSeries.name}$brakeSeries';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrakeSeries &&
          runtimeType == other.runtimeType &&
          trainSeries == other.trainSeries &&
          brakeSeries == other.brakeSeries;

  @override
  int get hashCode => trainSeries.hashCode ^ brakeSeries.hashCode;

  @override
  String toString() {
    return 'BrakeSeries{trainSeries: $trainSeries, brakeSeries: $brakeSeries}';
  }
}
