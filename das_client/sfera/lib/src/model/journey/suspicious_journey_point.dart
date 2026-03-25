import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

/// A journey point that belongs to a suspicious segment profile.
///
/// Problems in a suspicious segment typically occur because of incomplete or
/// wrong route table data (the RADN document). All regular [BaseData]
/// items produced by that segment profile are replaced by a single
/// [SuspiciousJourneyPoint].
class SuspiciousJourneyPoint extends JourneyPoint {
  const SuspiciousJourneyPoint({
    required super.order,
    required super.kilometre,
    required this.spId,
  }) : super(dataType: Datatype.suspiciousJourneyPoint);

  final String spId;

  @override
  OrderPriority get orderPriority => OrderPriority.baseData;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is SuspiciousJourneyPoint && other.order == order);

  @override
  int get hashCode => Object.hash(dataType, order);

  @override
  String toString() => 'SuspiciousJourneyPoint{order: $order, kilometre: $kilometre, spId: $spId}';
}
