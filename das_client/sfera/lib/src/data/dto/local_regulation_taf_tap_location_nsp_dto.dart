import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class LocalRegulationTafTapLocationNspDto({super.type, super.attributes, super.children, super.value})
    extends TafTapLocationNspDto {
  static const String groupNameValueStart = 'localRegulation';

  String? get languageNeutralTree => children.whereNspWithName('languageNeutralTree').firstOrNull?.nspValue;
}
