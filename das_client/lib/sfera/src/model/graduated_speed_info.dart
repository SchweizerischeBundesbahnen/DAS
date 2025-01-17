import 'package:das_client/sfera/src/model/graduated_speed_info_entity.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class GraduatedSpeedInfo extends SferaXmlElement {
  static const String elementType = 'entries';

  GraduatedSpeedInfo({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<GraduatedSpeedInfoEntity> get entities => children.whereType<GraduatedSpeedInfoEntity>();
}
