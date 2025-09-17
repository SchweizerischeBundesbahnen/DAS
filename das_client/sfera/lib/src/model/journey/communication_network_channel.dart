import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class CommunicationNetworkChannel extends JourneyPoint {
  const CommunicationNetworkChannel({
    required super.order,
    required super.kilometre,
    required this.communicationNetworkType,
  }) : super(type: Datatype.communicationNetworkChannel);

  final CommunicationNetworkType communicationNetworkType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationNetworkChannel &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          communicationNetworkType == other.communicationNetworkType &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre) ^ communicationNetworkType.hashCode;

  @override
  String toString() {
    return 'CommunicationNetworkChannel('
        'order: $order '
        'kilometre: $kilometre '
        'communicationNetworkType: $communicationNetworkType'
        ')';
  }
}
