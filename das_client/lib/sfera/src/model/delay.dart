import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:fimber/fimber.dart';
import 'package:iso_duration/iso_duration.dart';

class Delay extends SferaXmlElement {
  static const String elementType = 'Delay';

  Delay({super.type = elementType, super.attributes, super.children, super.value});

  String? get delay => attributes['Delay'];

  @override
  bool validate() {
    return validateHasAttribute('Delay') && super.validate();
  }

  Duration? get delayAsDuration {
    if (delay == null) {
      return null;
    }
    try {
      return tryParseIso8601Duration(delay);
    } catch (error) {
      Fimber.w('An error occurred while trying to parse $delay to a duration. Here the error: $error');
      return null;
    }
  }
}
