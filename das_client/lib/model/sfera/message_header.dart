import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/train_identification.dart';

class MessageHeader extends SferaXmlElement {
  static const String elementType = 'MessageHeader';

  MessageHeader({super.type = elementType, super.attributes, super.children, super.value});

  factory MessageHeader.create(String messageId, String timestamp, String sourceDevice, String destinationDevice,
      String sender, String recipient, {TrainIdentification? trainIdentification}) {
    final messageHeader = MessageHeader();
    messageHeader.attributes['SFERA_version'] = '2.01';
    messageHeader.attributes['message_ID'] = messageId;
    messageHeader.attributes['timestamp'] = timestamp;
    messageHeader.attributes['sourceDevice'] = sourceDevice;
    messageHeader.attributes['destinationDevice'] = destinationDevice;
    if (trainIdentification != null) {
      messageHeader.children.add(trainIdentification);
    }
    messageHeader.children.add(SferaXmlElement(type: 'Sender', value: sender));
    messageHeader.children.add(SferaXmlElement(type: 'Recipient', value: recipient));
    return messageHeader;
  }

  String get sferaVersion => attributes['SFERA_version']!;

  String get messageId => attributes['message_ID']!;

  String get correlationId => attributes['correlation_ID']!;

  String get timestamp => attributes['timestamp']!;

  String get sourceDevice => attributes['timestamp']!;

  String get sender => childrenWithType('Sender').first.value!;

  String get recipient => childrenWithType('Recipient').first.value!;

  @override
  bool validate() {
    return validateHasChild('Sender') &&
        validateHasChild('Recipient') &&
        validateHasAttribute('SFERA_version') &&
        validateHasAttribute('message_ID') &&
        validateHasAttribute('timestamp') &&
        validateHasAttribute('sourceDevice') &&
        super.validate();
  }
}
