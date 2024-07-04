import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class B2gRequest extends SferaXmlElement {
  static const String elementType = "B2G_Request";

  B2gRequest({super.type = elementType, super.attributes, super.children, super.value});

}
