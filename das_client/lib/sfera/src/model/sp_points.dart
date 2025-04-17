import 'package:collection/collection.dart';
import 'package:das_client/sfera/src/model/balise.dart';
import 'package:das_client/sfera/src/model/balise_group.dart';
import 'package:das_client/sfera/src/model/curve_point_network_specific_point.dart';
import 'package:das_client/sfera/src/model/network_specific_point.dart';
import 'package:das_client/sfera/src/model/new_line_speed_network_specific_point.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/signal.dart';
import 'package:das_client/sfera/src/model/timing_point.dart';
import 'package:das_client/sfera/src/model/track_foot_notes_nsp.dart';
import 'package:das_client/sfera/src/model/virtual_balise.dart';
import 'package:das_client/sfera/src/model/whistle_network_specific_point.dart';

class SpPoints extends SferaXmlElement {
  static const String elementType = 'SP_Points';
  static const String _protectionSectionNspName = 'protectionSection';

  SpPoints({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TimingPoint> get timingPoints => children.whereType<TimingPoint>();

  Iterable<Signal> get signals => children.whereType<Signal>();

  Iterable<VirtualBalise> get virtualBalise => children.whereType<VirtualBalise>();

  Iterable<BaliseGroup> get baliseGroupes => children.whereType<BaliseGroup>();

  Iterable<Balise> get balises => baliseGroupes.map((group) => group.balise).flattened;

  Iterable<NetworkSpecificPoint> get protectionSectionNsp =>
      children.whereType<NetworkSpecificPoint>().where((it) => it.groupName == _protectionSectionNspName);

  Iterable<NewLineSpeedNetworkSpecificPoint> get newLineSpeedsNsp =>
      children.whereType<NewLineSpeedNetworkSpecificPoint>();

  Iterable<CurvePointNetworkSpecificPoint> get curvePointsNsp => children.whereType<CurvePointNetworkSpecificPoint>();

  Iterable<WhistleNetworkSpecificPoint> get whistleNsp => children.whereType<WhistleNetworkSpecificPoint>();

  Iterable<TrackFootNotesNsp> get trackFootNotesNsp => children.whereType<TrackFootNotesNsp>();
}
