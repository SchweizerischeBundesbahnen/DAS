sealed class const SuspiciousSegmentModel._() {
  factory SuspiciousSegmentModel.hidden() = SuspiciousSegmentHidden;

  factory SuspiciousSegmentModel.visible() = SuspiciousSegmentVisible;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class const SuspiciousSegmentHidden() extends SuspiciousSegmentModel {
  this : super._();

  @override
  String toString() => 'SuspiciousSegmentHidden{}';
}

class const SuspiciousSegmentVisible() extends SuspiciousSegmentModel {
  this : super._();

  @override
  String toString() => 'SuspiciousSegmentVisible{}';
}
