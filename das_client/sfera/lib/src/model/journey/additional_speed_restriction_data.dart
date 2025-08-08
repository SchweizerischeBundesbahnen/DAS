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
    return 'AdditionalSpeedRestrictionData(order: $order, kilometre: $kilometre, restrictions: $restrictions)';
  }
}
