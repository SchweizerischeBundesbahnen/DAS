import 'package:sfera/src/model/enums/start_end_qualifier.dart';
import 'package:sfera/src/model/enums/xml_enum.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:app/util/util.dart';

class SferaSegmentXmlElement extends SferaXmlElement {
  SferaSegmentXmlElement({required super.type, super.attributes, super.children, super.value});

  StartEndQualifier get startEndQualifier =>
      XmlEnum.valueOf(StartEndQualifier.values, attributes['startEndQualifier']!)!;

  double? get startLocation => Util.tryParseDouble(attributes['startLocation']);

  double? get endLocation => Util.tryParseDouble(attributes['endLocation']);

  @override
  bool validate() {
    return validateHasAttribute('startEndQualifier') && super.validate();
  }
}
