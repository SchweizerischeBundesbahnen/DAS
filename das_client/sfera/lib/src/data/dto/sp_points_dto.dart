import 'package:collection/collection.dart';
import 'package:sfera/src/data/dto/balise_dto.dart';
import 'package:sfera/src/data/dto/balise_group_dto.dart';
import 'package:sfera/src/data/dto/curve_point_network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/signal_dto.dart';
import 'package:sfera/src/data/dto/timing_point_dto.dart';
import 'package:sfera/src/data/dto/track_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/virtual_balise_dto.dart';
import 'package:sfera/src/data/dto/whistle_network_specific_point_dto.dart';

class SpPointsDto extends SferaXmlElementDto {
  static const String elementType = 'SP_Points';
  static const String _protectionSectionNspName = 'protectionSection';

  SpPointsDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TimingPointDto> get timingPoints => children.whereType<TimingPointDto>();

  Iterable<SignalDto> get signals => children.whereType<SignalDto>();

  Iterable<VirtualBaliseDto> get virtualBalise => children.whereType<VirtualBaliseDto>();

  Iterable<BaliseGroupDto> get baliseGroupes => children.whereType<BaliseGroupDto>();

  Iterable<BaliseDto> get balises => baliseGroupes.map((group) => group.balise).flattened;

  Iterable<NetworkSpecificPointDto> get protectionSectionNsp =>
      children.whereType<NetworkSpecificPointDto>().where((it) => it.groupName == _protectionSectionNspName);

  Iterable<NewLineSpeedNetworkSpecificPointDto> get newLineSpeedsNsp =>
      children.whereType<NewLineSpeedNetworkSpecificPointDto>();

  Iterable<CurvePointNetworkSpecificPointDto> get curvePointsNsp =>
      children.whereType<CurvePointNetworkSpecificPointDto>();

  Iterable<WhistleNetworkSpecificPointDto> get whistleNsp => children.whereType<WhistleNetworkSpecificPointDto>();

  Iterable<TrackFootNotesNspDto> get trackFootNotesNsp => children.whereType<TrackFootNotesNspDto>();
}
