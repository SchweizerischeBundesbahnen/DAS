enum ShortTermChangeType {
  endDestination,
  trainRunRerouting,
  stop2Pass,
  pass2Stop,
}

sealed class ShortTermChangeModel {
  const ShortTermChangeModel._();

  factory ShortTermChangeModel.noShortTermChanges() = NoShortTermChanges;

  factory ShortTermChangeModel.singleShortTermChange({
    required ShortTermChangeType shortTermChangeType,
    String? servicePointName,
  }) = SingleShortTermChange;

  factory ShortTermChangeModel.multipleShortTermChanges() = MultipleShortTermChanges;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class NoShortTermChanges extends ShortTermChangeModel {
  const NoShortTermChanges() : super._();

  @override
  String toString() => 'NoShortTermChanges()';
}

class SingleShortTermChange extends ShortTermChangeModel {
  const SingleShortTermChange({
    required this.shortTermChangeType,
    this.servicePointName,
  }) : super._();

  final ShortTermChangeType shortTermChangeType;
  final String? servicePointName;

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
  String toString() =>
      'SingleShortTermChange(shortTermChangeType: $shortTermChangeType, servicePointName: $servicePointName)';
}

class MultipleShortTermChanges extends ShortTermChangeModel {
  const MultipleShortTermChanges() : super._();

  @override
  String toString() => 'MultipleShortTermChanges()';
}
