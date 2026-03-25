sealed class SuspiciousSegmentModel {
  const SuspiciousSegmentModel._();

  factory SuspiciousSegmentModel.hidden() = SuspiciousSegmentHidden;

  factory SuspiciousSegmentModel.visible() = SuspiciousSegmentVisible;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class SuspiciousSegmentHidden extends SuspiciousSegmentModel {
  const SuspiciousSegmentHidden() : super._();

  @override
  String toString() => 'SuspiciousSegmentHidden{}';
}

class SuspiciousSegmentVisible extends SuspiciousSegmentModel {
  const SuspiciousSegmentVisible() : super._();

  @override
  String toString() => 'SuspiciousSegmentVisible{}';
}
