import 'package:formation/src/api/converter/transport_paper_link_type_converter.dart';
import 'package:formation/src/model/transport_paper_link_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transport_paper_link.g.dart';

@JsonSerializable()
class TransportPaperLink({
  required final String url,
  @TransportPaperLinkTypeConverter() required final TransportPaperLinkType type,
}) {
  factory fromJson(Map<String, dynamic> json) => _$TransportPaperLinkFromJson(json);

  @override
  String toString() {
    return 'TransportPaperLink{url: $url, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportPaperLink && runtimeType == other.runtimeType && url == other.url && type == other.type;

  @override
  int get hashCode => Object.hash(url, type);
}
