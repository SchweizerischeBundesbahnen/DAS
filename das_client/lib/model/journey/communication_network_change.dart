import 'package:collection/collection.dart';

class CommunicationNetworkChange implements Comparable {
  CommunicationNetworkChange({required this.type, required this.order});

  final CommunicationNetworkType type;

  /// Marks the start from where this communication network applies.
  /// No start and end order is given, as RADN delivers network only for specific point.
  final int order;

  @override
  int compareTo(other) {
    if (other is! CommunicationNetworkChange) return -1;
    return order.compareTo(other.order);
  }

  @override
  String toString() {
    return 'CommunicationNetworkChange(type: $type, order: $order)';
  }
}

enum CommunicationNetworkType { gsmR, gsmP, sim }

// extensions

extension CommunicationNetworkChangeListExtension on Iterable<CommunicationNetworkChange> {
  /// Returns network type that applies to given [order].
  /// [CommunicationNetworkType.sim] is ignored as it is handled differently.
  CommunicationNetworkType? appliesToOrder(int order) {
    final sortedList = toList()..sort();
    return sortedList.reversed
        .firstWhereOrNull((network) => network.order <= order && network.type != CommunicationNetworkType.sim)
        ?.type;
  }
}
