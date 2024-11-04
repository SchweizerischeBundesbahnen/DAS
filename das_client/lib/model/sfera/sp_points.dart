import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/signal.dart';
import 'package:das_client/model/sfera/timing_point.dart';
import 'package:das_client/model/sfera/virtual_balise.dart';

class SpPoints extends SferaXmlElement {
  static const String elementType = 'SP_Points';

  SpPoints({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TimingPoint> get timingPoints => children.whereType<TimingPoint>();

  Iterable<Signal> get signals => children.whereType<Signal>();

  Iterable<VirtualBalise> get balise => children.whereType<VirtualBalise>();
}
