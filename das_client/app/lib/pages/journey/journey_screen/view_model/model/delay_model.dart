import 'package:intl/intl.dart';
import 'package:sfera/component.dart';

sealed class const DelayModel._() {
  factory DelayModel.visible({required Delay delay}) = Visible;

  factory DelayModel.stale({required Delay delay}) = Stale;

  factory DelayModel.hidden() = Hidden;

  factory DelayModel.plannedTimeDeviation({required Duration deviation}) = PlannedTimeDeviation;

  String get formattedDelay => switch (this) {
    final Visible v => v.delay.formatted,
    final Stale s => s.delay.formatted,
    final PlannedTimeDeviation p => p.deviation.formattedPlannedTimeDeviation,
    final Hidden _ => '',
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class const Visible({required final Delay delay}) extends DelayModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Visible && runtimeType == other.runtimeType && delay == other.delay;

  @override
  int get hashCode => Object.hash(runtimeType, delay);

  @override
  String toString() {
    return 'Visible{delay: $delay}';
  }
}

class const Stale({required final Delay delay}) extends DelayModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Stale && runtimeType == other.runtimeType && delay == other.delay;

  @override
  int get hashCode => Object.hash(runtimeType, delay);

  @override
  String toString() {
    return 'Stale{delay: $delay}';
  }
}

class const Hidden() extends DelayModel {
  this : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hidden && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Hidden{}';
  }
}

class const PlannedTimeDeviation({required final Duration deviation}) extends DelayModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedTimeDeviation && runtimeType == other.runtimeType && deviation == other.deviation;

  @override
  int get hashCode => Object.hash(runtimeType, deviation);

  @override
  String toString() {
    return 'PlannedTimeDeviation{deviation: $deviation}';
  }
}

extension _DelayExtension on Delay? {
  String get formatted {
    if (this == null) return '';

    final value = this!.value;

    final minutes = NumberFormat('00').format(value.inMinutes.abs());
    final seconds = NumberFormat('00').format(value.inSeconds.abs() % 60);
    return '${value.isNegative ? '-' : '+'}$minutes:$seconds';
  }
}

extension _PlannedTimeDeviationExtension on Duration {
  String get formattedPlannedTimeDeviation {
    final hours = NumberFormat('00').format(inHours.abs());
    final minutes = NumberFormat('00').format(inMinutes.abs() % 60);
    return '${isNegative ? '-' : '+'}${hours}h$minutes';
  }
}
