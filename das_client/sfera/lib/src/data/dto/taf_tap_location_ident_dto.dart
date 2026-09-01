import 'package:sfera/src/data/dto/location_ident_dto.dart';
import 'package:sfera/src/data/dto/teltsi_primary_location_name_dto.dart';

class TafTapLocationIdentDto({super.type = elementType, super.attributes, super.children, super.value})
    extends LocationIdentDto {
  static const String elementType = 'TAF_TAP_LocationIdent';

  TeltsiPrimaryLocationNameDto? get primaryLocationName =>
      children.whereType<TeltsiPrimaryLocationNameDto>().firstOrNull;
}
