import 'package:das_client/sfera/src/model/enums/foot_note_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class FootNote extends SferaXmlElement {
  static const String elementType = 'footNote';

  FootNote({super.type = elementType, super.attributes, super.children, super.value});

  String get text => childrenWithType('text').first.value!;

  String? get identifier => attributes['identifier'];

  String? get trainSeries => childrenWithType('trainSeries').firstOrNull?.value;

  FootNoteType? get footNoteType => XmlEnum.valueOf(FootNoteType.values, attributes['type']);

  String? get refText => attributes['refText'];

  @override
  bool validate() {
    return validateHasChild('text') && super.validate();
  }
}
