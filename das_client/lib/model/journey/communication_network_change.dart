import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class CommunicationNetworkChange implements Comparable {
  const CommunicationNetworkChange({required this.type, required this.order});

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

  /// Return the network type that changes at given [order].
  CommunicationNetworkType? changeAtOrder(int order) {
    final sortedList = where((it) => it.type != CommunicationNetworkType.sim).toList()..sort();
    final change = sortedList.firstWhereOrNull((it) => it.order == order);
    if (change == null) return null;
    final index = sortedList.indexOf(change);
    if (index == 0) {
      return change.type;
    } else {
      return sortedList[index - 1].type != change.type ? change.type : null;
    }
  }
}
