import 'package:collection/collection.dart';
import 'package:sfera/src/data/dto/departure_auth_nsp_dto.dart';
import 'package:sfera/src/data/dto/enums/modification_type_dto.dart';
import 'package:sfera/src/data/dto/enums/taf_tap_location_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/line_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_property_nsp_dto.dart';
import 'package:sfera/src/data/dto/station_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_ident_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_route_table_data_nsp_dto.dart';

class TafTapLocationDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'TAF_TAP_Location';

  TafTapLocationDto({super.type = elementType, super.attributes, super.children, super.value});

  TafTapLocationIdentDto get locationIdent => children.whereType<TafTapLocationIdentDto>().first;

  TafTapLocationTypeDto? get locationType =>
      XmlEnum.valueOf<TafTapLocationTypeDto>(TafTapLocationTypeDto.values, attributes['TAF_TAP_location_type']);

  String get abbreviation => attributes['TAF_TAP_location_abbreviation'] ?? '';

  Iterable<TafTapLocationNspDto> get nsps => children.whereType<TafTapLocationNspDto>();

  StationSpeedNspDto? get stationSpeed => children.whereType<StationSpeedNspDto>().firstOrNull;

  Iterable<LocalRegulationNspDto> get localRegulations => children.whereType<LocalRegulationNspDto>();

  NewLineSpeedTafTapLocationDto? get newLineSpeed => children.whereType<NewLineSpeedTafTapLocationDto>().firstOrNull;

  OpFootNotesNspDto? get opFootNotes => children.whereType<OpFootNotesNspDto>().firstOrNull;

  LineFootNotesNspDto? get lineFootNotes => children.whereType<LineFootNotesNspDto>().firstOrNull;

  TafTapRouteTableDataNspDto? get routeTableDataNsp => children.whereType<TafTapRouteTableDataNspDto>().firstOrNull;

  DepartureAuthNspDto? get departureAuthNsp => children.whereType<DepartureAuthNspDto>().firstOrNull;

  StationPropertyNspDto? get property => children.whereType<StationPropertyNspDto>().firstOrNull;

  Iterable<NspDto> get _allModificationsDesc => <NspDto>[...nsps, ?property]
      .where((it) => it.lastModificationDate != null)
      .sorted((b, a) => a.lastModificationDate!.compareTo(b.lastModificationDate!));

  DateTime? get lastModificationDate => _allModificationsDesc.firstOrNull?.lastModificationDate;

  ModificationTypeDto? get lastModificationType => _allModificationsDesc.firstOrNull?.lastModificationType;

  @override
  bool validate() {
    return validateHasChildOfType<TafTapLocationIdentDto>() && super.validate();
  }
}

extension TafTapLocationDtoIterableExtension on Iterable<TafTapLocationDto> {
  TafTapLocationDto firstWhereGiven({String? countryCode, int? primaryCode}) =>
      _whereGiven(countryCode, primaryCode).first;

  TafTapLocationDto? firstWhereGivenOrNull({String? countryCode, int? primaryCode}) =>
      _whereGiven(countryCode, primaryCode).firstOrNull;

  Iterable<TafTapLocationDto> _whereGiven(String? countryCode, int? primaryCode) {
    return where(
      (it) => it.locationIdent.countryCodeISO == countryCode && it.locationIdent.locationPrimaryCode == primaryCode,
    );
  }
}
