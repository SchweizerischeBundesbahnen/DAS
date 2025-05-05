import 'package:sfera/src/model/enums/stop_skip_pass.dart';
import 'package:sfera/src/model/enums/xml_enum.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/stopping_point_information.dart';
import 'package:sfera/src/model/timing_point_reference.dart';

class TimingPointConstraints extends SferaXmlElement {
  static const String elementType = 'TimingPointConstraints';

  TimingPointConstraints({super.type = elementType, super.attributes, super.children, super.value});

  TimingPointReference get timingPointReference => children.whereType<TimingPointReference>().first;

  StoppingPointInformation? get stoppingPointInformation => children.whereType<StoppingPointInformation>().firstOrNull;

  StopSkipPass get stopSkipPass =>
      XmlEnum.valueOf<StopSkipPass>(StopSkipPass.values, attributes['TP_StopSkipPass']) ?? StopSkipPass.stoppingPoint;

  @override
  bool validate() {
    return validateHasChildOfType<TimingPointReference>() && super.validate();
  }
}
