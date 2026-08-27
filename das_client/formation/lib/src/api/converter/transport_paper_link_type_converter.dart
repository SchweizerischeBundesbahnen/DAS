import 'package:formation/src/model/transport_paper_link_type.dart';
import 'package:json_annotation/json_annotation.dart';

class const TransportPaperLinkTypeConverter() implements JsonConverter<TransportPaperLinkType, String> {
  @override
  TransportPaperLinkType fromJson(String value) => TransportPaperLinkType.fromString(value);

  @override
  String toJson(TransportPaperLinkType type) => type.value;
}
