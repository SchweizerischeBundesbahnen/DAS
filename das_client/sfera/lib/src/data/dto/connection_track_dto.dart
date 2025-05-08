import 'package:sfera/src/data/dto/connection_track_description_dto.dart';
import 'package:sfera/src/data/dto/enums/connection_track_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sp_generic_point_dto.dart';

class ConnectionTrackDto extends SpGenericPointDto {
  static const String elementType = 'ConnectionTrack';

  ConnectionTrackDto({super.type = elementType, super.attributes, super.children, super.value});

  ConnectionTrackTypeDto get connectionTrackType => XmlEnum.valueOfOr(
      ConnectionTrackTypeDto.values, attributes['connectionTrackType'], ConnectionTrackTypeDto.unknown);

  ConnectionTrackDescriptionDto? get connectionTrackDescription =>
      children.whereType<ConnectionTrackDescriptionDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('connectionTrackType') && super.validate();
  }
}
