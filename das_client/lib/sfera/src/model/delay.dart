import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class DelaySfera extends SferaXmlElement{
  static const String elementType = 'DelaySfera';

  DelaySfera({
    required this.delayTime, super.attributes, super.children, super.value, required super.type
  });

  final Duration delayTime;


  @override
  bool validate() {
    return validateHasChildOfType<DelaySfera>() && super.validate();
  }
}