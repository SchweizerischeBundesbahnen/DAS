import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class LocalRegulationNetworkSpecificPointNspDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificPointDto {
  static const String groupNameValue = 'localRegulations';

  String? get title => children.whereNspWithName('title').firstOrNull?.nspValue;

  String? get content => children.whereNspWithName('content').firstOrNull?.nspValue;

  String? get localRegulationChildren => children.whereNspWithName('children').firstOrNull?.nspValue;
}
