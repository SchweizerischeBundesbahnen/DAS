import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class DepartureAuthNspDto({super.type, super.attributes, super.children, super.value}) extends TafTapLocationNspDto {
  static const String groupNameValue = 'departureAuth';

  bool get departureAuth =>
      children.whereNspWithName('departureAuth').map((it) => bool.tryParse(it.nspValue)).firstOrNull ?? false;

  bool get departureAuthDispatcher =>
      children.whereNspWithName('departureAuthDispatcher').map((it) => bool.tryParse(it.nspValue)).firstOrNull ?? false;

  String? get departureAuthText => children.whereNspWithName('departureAuthText').firstOrNull?.nspValue;
}
