import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class TrainIdentification extends SferaXmlElement {
  static const String elementType = "TrainIdentification";

  TrainIdentification({required super.type, super.attributes, super.children, super.value});
}
