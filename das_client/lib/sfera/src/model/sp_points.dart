import 'package:das_client/sfera/src/model/network_specific_point.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/signal.dart';
import 'package:das_client/sfera/src/model/timing_point.dart';
import 'package:das_client/sfera/src/model/virtual_balise.dart';

class SpPoints extends SferaXmlElement {
  static const String elementType = 'SP_Points';
  static const String _protectionSectionNspName = 'protectionSection';
  static const String _curvePointName = 'curvePoint';

  SpPoints({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TimingPoint> get timingPoints => children.whereType<TimingPoint>();

  Iterable<Signal> get signals => children.whereType<Signal>();

  Iterable<NetworkSpecificPoint> get curvePointsNsp =>
      children.whereType<NetworkSpecificPoint>().where((it) => it.name == _curvePointName);

  Iterable<VirtualBalise> get balise => children.whereType<VirtualBalise>();

  Iterable<NetworkSpecificPoint> get protectionSectionNsp =>
      children.whereType<NetworkSpecificPoint>().where((it) => it.name == SpPoints._protectionSectionNspName);
}
