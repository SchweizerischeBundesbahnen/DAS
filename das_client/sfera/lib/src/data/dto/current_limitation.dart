import 'package:sfera/src/data/dto/current_limitation_change.dart';
import 'package:sfera/src/data/dto/current_limitation_start.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class CurrentLimitation extends SferaXmlElement {
  static const String elementType = 'CurrentLimitation';

  CurrentLimitation({super.type = elementType, super.attributes, super.children, super.value});

  CurrentLimitationStart get currentLimitationStart => children.whereType<CurrentLimitationStart>().first;

  Iterable<CurrentLimitationChange> get currentLimitationChanges => children.whereType<CurrentLimitationChange>();

  @override
  bool validate() {
    return validateHasChildOfType<CurrentLimitationStart>() && super.validate();
  }
}
