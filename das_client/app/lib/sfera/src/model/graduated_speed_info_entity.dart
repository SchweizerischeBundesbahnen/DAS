import 'package:app/sfera/src/model/sfera_xml_element.dart';

class GraduatedSpeedInfoEntity extends SferaXmlElement {
  static const String elementType = 'entry';

  GraduatedSpeedInfoEntity({super.type = elementType, super.attributes, super.children, super.value});

  String? get nSpeed => attributes['nSpeed'];

  String? get roSpeed => attributes['roSpeed'];

  String? get adSpeed => attributes['adSpeed'];

  String? get sSpeed => attributes['sSpeed'];

  String? get text => attributes['text'];
}
