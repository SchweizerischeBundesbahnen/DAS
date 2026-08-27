import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class const BrakeSeries({
  required final TrainSeries trainSeries,
  required final int brakedWeightPercentage,
}) {
  /// returns train series name + braked weight percentage (ie. R150)
  String get name => '${trainSeries.name}$brakedWeightPercentage';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrakeSeries &&
          runtimeType == other.runtimeType &&
          trainSeries == other.trainSeries &&
          brakedWeightPercentage == other.brakedWeightPercentage;

  @override
  int get hashCode => trainSeries.hashCode ^ brakedWeightPercentage.hashCode;

  @override
  String toString() {
    return 'BrakeSeries{trainSeries: $trainSeries, brakedWeightPercentage: $brakedWeightPercentage}';
  }
}
