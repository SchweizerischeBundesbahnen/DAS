import 'package:das_client/model/journey/train_series.dart';
import 'package:meta/meta.dart';

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
