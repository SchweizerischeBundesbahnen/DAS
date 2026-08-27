import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class const CommunicationNetworkChange({
  required final CommunicationNetworkType communicationNetworkType,
  required super.order,
  final bool isServicePoint = false,
  super.kilometre = const [],
}) extends JourneyPoint {
  this : super(dataType: .communicationNetworkChannel);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationNetworkChange &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          communicationNetworkType == other.communicationNetworkType &&
          const ListEquality<double>().equals(kilometre, other.kilometre);

  @override
  int get hashCode => Object.hash(dataType, order, communicationNetworkType, Object.hashAll(kilometre));

  @override
  String toString() {
    return 'CommunicationNetworkChange{order: $order, kilometre: $kilometre, communicationNetworkType: $communicationNetworkType}';
  }
}

enum CommunicationNetworkType { gsmR, gsmP }

extension CommunicationNetworkChangeListExtension on Iterable<CommunicationNetworkChange> {
  /// Returns network type that returns last lower or equal to given [order].
  CommunicationNetworkType? typeByLastBefore(int order) {
    final sortedList = toList()..sort();
    return sortedList.reversed.firstWhereOrNull((network) => network.order <= order)?.communicationNetworkType;
  }

  /// Return the network type that changes at given [order].
  CommunicationNetworkType? changeAtOrder(int order) {
    final sortedList = toList()..sort();
    final change = sortedList.firstWhereOrNull((it) => it.order == order);
    if (change == null) return null;
    final index = sortedList.indexOf(change);
    if (index == 0) {
      return change.communicationNetworkType;
    } else {
      return sortedList[index - 1].communicationNetworkType != change.communicationNetworkType
          ? change.communicationNetworkType
          : null;
    }
  }
}
