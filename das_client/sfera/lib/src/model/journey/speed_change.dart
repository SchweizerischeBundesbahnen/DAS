import 'package:sfera/component.dart';

class SpeedChange extends JourneyPoint {
  const SpeedChange({required super.order, required super.kilometre, this.text}) : super(type: Datatype.speedChange);

  final String? text;
}
