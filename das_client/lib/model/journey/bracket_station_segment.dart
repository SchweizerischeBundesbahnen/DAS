class BracketStationSegment {
  const BracketStationSegment({
    required this.mainStationAbbreviation,
    required this.startOrder,
    required this.endOrder,
  });

  final String mainStationAbbreviation;

  /// Start order of this segment.
  final int startOrder;

  /// End order of this segment.
  final int endOrder;

  /// checks if the given order is part of this bracket station.
  bool appliesToOrder(int order) => startOrder <= order && order <= endOrder;

  @override
  String toString() {
    return 'BracketStationSegment(mainStationAbbreviation: $mainStationAbbreviation, startOrder: $startOrder, endOrder: $endOrder)';
  }
}

// extensions

extension BracketStationSegmentsExtension on Iterable<BracketStationSegment> {
  BracketStationSegment? appliesToOrder(int order) => where((segment) => segment.appliesToOrder(order)).firstOrNull;
}
