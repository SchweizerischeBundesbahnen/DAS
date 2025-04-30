import 'package:app/sfera/src/model/speeds.dart';

class StationSpeed extends Speeds {
  static const String elementType = 'stationSpeed';

  StationSpeed({super.type = elementType, super.attributes, super.children, super.value});
}
