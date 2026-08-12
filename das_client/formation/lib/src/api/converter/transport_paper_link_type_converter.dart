import 'package:formation/src/model/transport_paper_link_type.dart';
import 'package:json_annotation/json_annotation.dart';

class TransportPaperLinkTypeConverter implements JsonConverter<TransportPaperLinkType, String> {
  const TransportPaperLinkTypeConverter();

  @override
  TransportPaperLinkType fromJson(String value) {
    return TransportPaperLinkType.fromString(value);
  }

  @override
  String toJson(TransportPaperLinkType type) => type.value;
}
