import 'package:app/model/journey/additional_speed_restriction.dart';
import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/datatype.dart';

class AdditionalSpeedRestrictionData extends BaseData {
  const AdditionalSpeedRestrictionData({required this.restriction, required super.order, required super.kilometre})
      : super(type: Datatype.additionalSpeedRestriction);

  final AdditionalSpeedRestriction restriction;

  @override
  String toString() {
    return 'AdditionalSpeedRestrictionData(order: $order, kilometre: $kilometre, restriction: $AdditionalSpeedRestriction)';
  }
}
