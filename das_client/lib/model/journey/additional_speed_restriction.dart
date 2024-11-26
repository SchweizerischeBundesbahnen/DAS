

class AdditionalSpeedRestriction {
  AdditionalSpeedRestriction(
      {required this.kmFrom, required this.kmTo, required this.orderFrom, required this.orderTo, this.speed});

  final double kmFrom;
  final double kmTo;
  final int orderFrom;
  final int orderTo;
  final int? speed;
}
