import 'package:das_client/sfera/src/model/location_ident.dart';
import 'package:das_client/sfera/src/model/teltsi_primary_location_name.dart';

class TafTapLocationIdent extends LocationIdent {
  static const String elementType = 'TAF_TAP_LocationIdent';

  TafTapLocationIdent({
    super.type = elementType,
    super.attributes,
    super.children,
    super.value,
  });

  TeltsiPrimaryLocationName? get primaryLocationName => children.whereType<TeltsiPrimaryLocationName>().firstOrNull;
}
