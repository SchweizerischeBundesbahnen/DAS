import 'package:das_client/model/journey/base_data.dart';

class AdditionalSpeedRestriction {
  AdditionalSpeedRestriction(
      {required this.kmFrom, required this.kmTo, required this.orderFrom, required this.orderTo, this.speed});

  final double kmFrom;
  final double kmTo;
  final int orderFrom;
  final int orderTo;
  final int? speed;

  bool needsEndMarker(List<BaseData> journeyData) {
    return journeyData.where((it) => it.order >= orderFrom && it.order <= orderTo).length > 1;
  }
}
