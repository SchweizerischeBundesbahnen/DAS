import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class Velocity {
  const Velocity({
    required this.trainSeries,
    required this.reduced,
    this.breakSeries,
    this.speed,
  });

  final TrainSeries trainSeries;
  final int? breakSeries;
  final String? speed;
  final bool reduced;
}
