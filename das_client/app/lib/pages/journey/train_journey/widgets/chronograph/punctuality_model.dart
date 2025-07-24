sealed class PunctualityModel {
  const PunctualityModel._();

  factory PunctualityModel.visible({
    required String delay,
  }) = Visible;

  factory PunctualityModel.stale({
    required String delay,
  }) = Stale;

  factory PunctualityModel.hidden() = Hidden;

  String get delay => switch (this) {
    final Visible v => v.delay,
    final Stale s => s.delay,
    final Hidden _ => '',
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Visible extends PunctualityModel {
  const Visible({required this.delay}) : super._();
  @override
  final String delay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Visible && runtimeType == other.runtimeType && delay == other.delay;

  @override
  int get hashCode => Object.hash(runtimeType, delay);
}

class Stale extends PunctualityModel {
  const Stale({required this.delay}) : super._();
  @override
  final String delay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Stale && runtimeType == other.runtimeType && delay == other.delay;

  @override
  int get hashCode => Object.hash(runtimeType, delay);
}

class Hidden extends PunctualityModel {
  const Hidden() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hidden && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
