import 'package:das_client/sfera/src/model/enums/foot_note_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/text.dart';

class FootNote extends SferaXmlElement {
  static const String elementType = 'footNote';

  FootNote({super.type = elementType, super.attributes, super.children, super.value});

  String get text => children.whereType<Text>().first.xmlValue;

  String? get identifier => attributes['identifier'];

  String? get trainSeries => childrenWithType('trainSeries').firstOrNull?.value;

  SferaFootNoteType? get footNoteType => XmlEnum.valueOf(SferaFootNoteType.values, attributes['type']);

  String? get refText => attributes['refText'];

  @override
  bool validate() {
    return validateHasChild('text') && super.validate();
  }
}
