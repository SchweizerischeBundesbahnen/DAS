import 'package:sfera/src/data/dto/graduated_speed_info_entity.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class GraduatedSpeedInfo extends SferaXmlElement {
  static const String elementType = 'entries';

  GraduatedSpeedInfo({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<GraduatedSpeedInfoEntity> get entities => children.whereType<GraduatedSpeedInfoEntity>();
}
