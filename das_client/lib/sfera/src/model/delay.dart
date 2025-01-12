import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:fimber/fimber.dart';
import 'package:iso_duration/iso_duration.dart';

class Delay extends SferaXmlElement {
  static const String elementType = 'Delay';

  Delay({super.type = elementType, super.attributes, super.children, super.value});

  String get delay => attributes['Delay']!;

  @override
  bool validate() {
    return validateHasAttribute('Delay') && super.validate();
  }

  static Duration? toDuration(String? stringToChange) {
    //TODO anschauen, was mit über einer Stunde geschehen sollte (mit UX)
    final Duration? delay = tryParseIso8601Duration(stringToChange);

    if (delay == null) {
      Fimber.w('Invalid ISO 8601 duration format');
      return null;
    }
    return delay;
  }
}
