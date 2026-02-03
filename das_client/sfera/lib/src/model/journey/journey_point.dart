import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
abstract class JourneyPoint extends BaseData {
  static const showModificationDays = 30;

  const JourneyPoint({
    required super.dataType,
    required super.order,
    required this.kilometre,
    this.localSpeeds,
    this.lastModificationDate,
    this.lastModificationType,
  });

  final List<double> kilometre;
  final List<TrainSeriesSpeed>? localSpeeds;

  final DateTime? lastModificationDate;
  final ModificationType? lastModificationType;

  bool get hasModificationUpdated =>
      lastModificationType == ModificationType.updated &&
      lastModificationDate != null &&
      lastModificationDate!.isAfter(DateTime.now().add(Duration(days: -showModificationDays)));

  bool get shouldHide =>
      isDeleted &&
      lastModificationDate != null &&
      lastModificationDate!.isBefore(DateTime.now().add(Duration(days: -showModificationDays)));

  bool get isDeleted => lastModificationType == ModificationType.deleted;

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
