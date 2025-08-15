import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
abstract class JourneyPoint extends BaseData {
  const JourneyPoint({
    required super.type,
    required super.order,
    required this.kilometre,
    this.localSpeeds,
  });

  final List<double> kilometre;
  final List<TrainSeriesSpeed>? localSpeeds;

  /// Returns static local and line speeds. Does not return calculated or advised speed.
  Iterable<TrainSeriesSpeed> get allStaticSpeeds => [...?localSpeeds];
}
