import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
abstract class JourneyPoint extends BaseData {
  const JourneyPoint({
    required super.dataType,
    required super.order,
    required this.kilometre,
    this.localSpeeds,
  });

  final List<double> kilometre;
  final List<TrainSeriesSpeed>? localSpeeds;

  @override
  @mustBeOverridden
  int get hashCode;

  @override
  @mustBeOverridden
  bool operator ==(Object other);

  @override
  @mustBeOverridden
  String toString();

  /// Returns static local and line speeds. Does not return calculated or advised speed.
  Iterable<TrainSeriesSpeed> get allStaticSpeeds => [...?localSpeeds];
}
