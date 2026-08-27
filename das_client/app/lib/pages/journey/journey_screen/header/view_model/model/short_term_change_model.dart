enum ShortTermChangeType {
  endDestination,
  trainRunRerouting,
  stopToPass,
  passToStop,
}

sealed class const ShortTermChangeModel._() {
  factory noShortTermChanges() = NoShortTermChanges;

  factory singleShortTermChange({
    required ShortTermChangeType shortTermChangeType,
    String? servicePointName,
  }) = SingleShortTermChange;

  factory multipleShortTermChanges() = MultipleShortTermChanges;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class NoShortTermChanges extends ShortTermChangeModel {
  const NoShortTermChanges() : super._();

  @override
  String toString() {
    return 'NoShortTermChanges{}';
  }
}

class const SingleShortTermChange({
  required final ShortTermChangeType shortTermChangeType,
  final String? servicePointName,
}) extends ShortTermChangeModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleShortTermChange &&
          runtimeType == other.runtimeType &&
          shortTermChangeType == other.shortTermChangeType &&
          servicePointName == other.servicePointName;

  @override
  int get hashCode => Object.hash(runtimeType, shortTermChangeType, servicePointName);

  @override
  String toString() {
    return 'SingleShortTermChange{shortTermChangeType: $shortTermChangeType, servicePointName: $servicePointName}';
  }
}

class const MultipleShortTermChanges() extends ShortTermChangeModel {
  this : super._();

  @override
  String toString() {
    return 'MultipleShortTermChanges{}';
  }
}
