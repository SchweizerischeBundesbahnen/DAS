import 'package:das_client/sfera/src/model/network_specific_point.dart';
import 'package:das_client/sfera/src/model/xml_curve_speed.dart';
import 'package:das_client/sfera/src/model/xml_new_line_speed.dart';

class CurvePointNetworkSpecificPoint extends NetworkSpecificPoint {
  static const String elementName = 'curvePoint';

  CurvePointNetworkSpecificPoint({super.type, super.attributes, super.children, super.value});

  XmlCurveSpeed? get xmlCurveSpeed => parameters.whereType<XmlCurveSpeed>().firstOrNull;
}
