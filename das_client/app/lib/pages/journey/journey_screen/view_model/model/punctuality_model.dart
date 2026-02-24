import 'package:intl/intl.dart';
import 'package:sfera/component.dart';

sealed class PunctualityModel {
  const PunctualityModel._();

  factory PunctualityModel.visible({
    required Delay delay,
  }) = Visible;

  factory PunctualityModel.stale({
    required Delay delay,
  }) = Stale;

  factory PunctualityModel.hidden() = Hidden;

  String get formattedDelay => switch (this) {
    final Visible v => v.delay.formatted,
    final Stale s => s.delay.formatted,
    final Hidden _ => '',
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Visible extends PunctualityModel {
  const Visible({required this.delay}) : super._();
  final Delay delay;

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

class Stale extends PunctualityModel {
  const Stale({required this.delay}) : super._();
  final Delay delay;

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

class Hidden extends PunctualityModel {
  const Hidden() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hidden && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Hidden{}';
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
