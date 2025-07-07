sealed class PunctualityModel {
  const PunctualityModel._();

  factory PunctualityModel.visible({
    required String delayString,
  }) = Visible;

  factory PunctualityModel.stale({
    required String delayString,
  }) = Stale;

  factory PunctualityModel.hidden() = Hidden;

  String get delayString => switch (this) {
    final Visible v => v.delayString,
    final Stale s => s.delayString,
    final Hidden _ => '',
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Visible extends PunctualityModel {
  const Visible({required this.delayString}) : super._();
  @override
  final String delayString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Visible && runtimeType == other.runtimeType && delayString == other.delayString;

  @override
  int get hashCode => Object.hash(runtimeType, delayString);
}

class Stale extends PunctualityModel {
  const Stale({required this.delayString}) : super._();
  @override
  final String delayString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Stale && runtimeType == other.runtimeType && delayString == other.delayString;

  @override
  int get hashCode => Object.hash(runtimeType, delayString);
}

class Hidden extends PunctualityModel {
  const Hidden() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hidden && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
