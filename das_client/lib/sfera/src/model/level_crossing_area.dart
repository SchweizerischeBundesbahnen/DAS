import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/util/util.dart';

class LevelCrossingArea extends SferaXmlElement {
  static const String elementType = 'LevelCrossingArea';

  LevelCrossingArea({super.type = elementType, super.attributes, super.children, super.value});

  StartEndQualifier? get startEndQualifier =>
      XmlEnum.valueOf<StartEndQualifier>(StartEndQualifier.values, attributes['startEndQualifier']);

  double get startLocation => double.parse(attributes['startLocation']!);

  double? get endLocation => Util.tryParseDouble(attributes['endLocation']);

  @override
  bool validate() {
    return validateHasAttribute('startEndQualifier') && validateHasAttributeDouble('startLocation') && super.validate();
  }
}
