import 'package:sfera/component.dart';

class TramArea extends JourneyPoint {
  const TramArea({
    required super.order,
    required super.kilometre,
    required this.endKilometre,
    required this.amountTramSignals,
  }) : super(type: Datatype.tramArea);

  final double endKilometre;
  final int amountTramSignals;
}
