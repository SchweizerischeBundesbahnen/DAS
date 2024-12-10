import 'package:das_client/sfera/src/model/enums/connection_track_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sp_generic_point.dart';

class ConnectionTrack extends SpGenericPoint {
  static const String elementType = 'ConnectionTrack';

  ConnectionTrack({super.type = elementType, super.attributes, super.children, super.value});

  ConnectionTrackType get connectionTrackType =>
      XmlEnum.valueOfOr(ConnectionTrackType.values, attributes['connectionTrackType'], ConnectionTrackType.unknown);

  String? get connectionTrackDescription => attributes['connectionTrackDescription'];

  @override
  bool validate() {
    return validateHasAttribute('connectionTrackType') && super.validate();
  }
}
