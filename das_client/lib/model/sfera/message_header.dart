import 'package:das_client/model/sfera/sfera_xml_element.dart';

class MessageHeader extends SferaXmlElement {
  static const String elementType = "MessageHeader";

  MessageHeader({required super.type, super.attributes, super.children, super.value});

  String get sferaVersion => attributes["SFERA_version"];

  String get messageId => attributes["message_ID"];

  String get correlationId => attributes["correlation_ID"];

  String get timestamp => attributes["timestamp"];

  String get sourceDevice => attributes["timestamp"];

  String get sender => childrenWithType("Sender").first.value!;

  String get recipient => childrenWithType("Recipient").first.value!;

  @override
  bool validate() {
    return validateHasChild("Sender") &&
        validateHasChild("Recipient") &&
        validateHasAttribute("SFERA_version") &&
        validateHasAttribute("message_ID") &&
        validateHasAttribute("timestamp") &&
        validateHasAttribute("sourceDevice") &&
        super.validate();
  }
}
