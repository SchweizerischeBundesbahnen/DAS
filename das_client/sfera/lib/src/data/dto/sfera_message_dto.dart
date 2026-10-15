import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

/// A top level SFERA message, consisting of a [MessageHeaderDto] and its content.
mixin SferaMessageDto on SferaXmlElementDto {
  MessageHeaderDto get messageHeader => children.whereType<MessageHeaderDto>().first;

  /// Compact description for logs, as the full XML message can be several hundred kB, e.g.:
  ///
  /// `SFERA_G2B_ReplyMessage{messageId: 1a2b, correlationId: 9z8y, content: G2B_ReplyPayload[JourneyProfile, SegmentProfile]}`
  String get logSummary {
    final content = children.where((child) => child is! MessageHeaderDto).map(_describeWithChildTypes);
    return '$type{messageId: ${messageHeader.messageId}, '
        'correlationId: ${messageHeader.attributes['correlation_ID']}, '
        'content: ${content.join(', ')}}';
  }

  static String _describeWithChildTypes(SferaXmlElementDto element) {
    final childTypes = element.children.map((child) => child.type).toSet();
    return '${element.type}[${childTypes.join(', ')}]';
  }
}
