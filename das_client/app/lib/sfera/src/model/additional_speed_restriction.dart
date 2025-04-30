import 'package:app/sfera/src/model/sfera_xml_element.dart';

class AdditionalSpeedRestriction extends SferaXmlElement {
  static const String elementType = 'AdditionalSpeedRestriction';

  AdditionalSpeedRestriction({super.type = elementType, super.attributes, super.children, super.value});

  bool get asrFront => attributes['ASR_Front'] != null ? bool.tryParse(attributes['ASR_Front']!) ?? false : false;

  int? get asrSpeed => attributes['ASR_Speed'] != null ? int.tryParse(attributes['ASR_Speed']!) : null;
}
