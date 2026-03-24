import 'package:sfera/src/model/journey/datatype.dart';
import 'package:sfera/src/model/journey/journey_point.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

/// A journey point that belongs to a suspicious segment profile.
///
/// Problems in a suspicious segment typically occur because of incomplete or
/// wrong route table data (the RADN document). All regular [JourneyPoint]
/// items produced by that segment profile are replaced by
/// [SuspiciousJourneyPoint].
class SuspiciousJourneyPoint extends JourneyPoint {
  const SuspiciousJourneyPoint({
    required super.order,
    required super.kilometre,
  }) : super(dataType: Datatype.suspiciousJourneyPoint);

  @override
  OrderPriority get orderPriority => OrderPriority.baseData;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is SuspiciousJourneyPoint && other.order == order);

  @override
  int get hashCode => Object.hash(dataType, order);

  @override
  String toString() => 'SuspiciousJourneyPoint{order: $order, kilometre: $kilometre}';
}
