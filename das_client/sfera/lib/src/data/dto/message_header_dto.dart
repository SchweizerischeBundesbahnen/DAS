import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class MessageHeaderDto extends SferaXmlElementDto {
  static const String elementType = 'MessageHeader';

  MessageHeaderDto({super.type = elementType, super.attributes, super.children, super.value});

  factory MessageHeaderDto.create(String messageId, String timestamp, String sourceDevice, String destinationDevice,
      String sender, String recipient) {
    final messageHeader = MessageHeaderDto();
    messageHeader.attributes['SFERA_version'] = '3.00';
    messageHeader.attributes['message_ID'] = messageId;
    messageHeader.attributes['timestamp'] = timestamp;
    messageHeader.attributes['sourceDevice'] = sourceDevice;
    messageHeader.attributes['destinationDevice'] = destinationDevice;
    messageHeader.children.add(SferaXmlElementDto(type: 'Sender', value: sender));
    messageHeader.children.add(SferaXmlElementDto(type: 'Recipient', value: recipient));
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
