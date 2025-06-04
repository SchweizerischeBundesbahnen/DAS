import 'package:sfera/src/model/journey/additional_speed_restriction.dart';
import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class AdditionalSpeedRestrictionData extends BaseData {
  AdditionalSpeedRestrictionData({required this.restrictions, required super.order, required super.kilometre})
    : assert(restrictions.isNotEmpty),
      super(type: Datatype.additionalSpeedRestriction);

  factory AdditionalSpeedRestrictionData.start(List<AdditionalSpeedRestriction> restrictions) {
    if (restrictions.isEmpty) throw ArgumentError('Restrictions can not be empty');
    final startRestriction = restrictions.getByLowestOrderFrom;
    return AdditionalSpeedRestrictionData(
      restrictions: restrictions,
      order: startRestriction.orderFrom,
      kilometre: [startRestriction.kmFrom],
    );
  }

  factory AdditionalSpeedRestrictionData.end(List<AdditionalSpeedRestriction> restrictions) {
    if (restrictions.isEmpty) throw ArgumentError('Restrictions can not be empty');
    final endRestriction = restrictions.getByHighestOrderTo;
    return AdditionalSpeedRestrictionData(
      restrictions: restrictions,
      order: endRestriction.orderTo,
      kilometre: [endRestriction.kmTo],
    );
  }

  final List<AdditionalSpeedRestriction> restrictions;

  double get kmFrom => restrictions.getByLowestOrderFrom.kmFrom;

  double get kmTo => restrictions.getByHighestOrderTo.kmTo;

  int? get speed => restrictions.minimalSpeed;

  @override
  String toString() {
    return 'AdditionalSpeedRestrictionData(order: $order, kilometre: $kilometre, restrictions: $restrictions)';
  }
}
