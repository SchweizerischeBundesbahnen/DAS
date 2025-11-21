import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionData extends JourneyPoint {
  AdditionalSpeedRestrictionData({required this.restrictions, required super.order, required super.kilometre})
    : assert(restrictions.isNotEmpty),
      super(type: Datatype.additionalSpeedRestriction);

  factory AdditionalSpeedRestrictionData.start(List<AdditionalSpeedRestriction> restrictions) {
    if (restrictions.isEmpty) throw ArgumentError('Restrictions can not be empty');
    final startRestriction = restrictions.getLowestByOrderFrom;
    return AdditionalSpeedRestrictionData(
      restrictions: restrictions,
      order: startRestriction.orderFrom,
      kilometre: [startRestriction.kmFrom],
    );
  }

  factory AdditionalSpeedRestrictionData.end(List<AdditionalSpeedRestriction> restrictions) {
    if (restrictions.isEmpty) throw ArgumentError('Restrictions can not be empty');
    final endRestriction = restrictions.getHighestByOrderTo;
    return AdditionalSpeedRestrictionData(
      restrictions: restrictions,
      order: endRestriction.orderTo,
      kilometre: [endRestriction.kmTo],
    );
  }

  final List<AdditionalSpeedRestriction> restrictions;

  double get kmFrom => restrictions.getLowestByOrderFrom.kmFrom;

  double get kmTo => restrictions.getHighestByOrderTo.kmTo;

  int? get speed => restrictions.minSpeed;

  @override
  String toString() {
    return 'AdditionalSpeedRestrictionData{order: $order, kilometre: $kilometre, restrictions: $restrictions}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalSpeedRestrictionData &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          ListEquality().equals(restrictions, other.restrictions);

  @override
  int get hashCode => type.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ Object.hashAll(restrictions);
}
