import 'package:das_client/sfera/src/model/enums/direction_of_application_on_sp.dart';
import 'package:das_client/sfera/src/model/enums/gradient_direction_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_segment_xml_element.dart';

class DecisiveGradientArea extends SferaSegmentXmlElement {
  static const String elementType = 'DecisiveGradientArea';

  DecisiveGradientArea({super.type = elementType, super.attributes, super.children, super.value});

  double get gradientValue => double.parse(attributes['gradientValue']!);

  GradientDirectionType get gradientDirectionType =>
      XmlEnum.valueOf(GradientDirectionType.values, attributes['gradientDirection'])!;

  DirectionOfApplicationOnSP get directionOfApplicationOnSP =>
      XmlEnum.valueOf(DirectionOfApplicationOnSP.values, attributes['directionOfApplicationOnSP'])!;

  @override
  bool validate() =>
      super.validate() &&
      validateHasAttributeDouble('gradientValue') &&
      validateHasAttributeInRange('gradientDirection', XmlEnum.values(GradientDirectionType.values)) &&
      validateHasAttributeInRange('directionOfApplicationOnSP', XmlEnum.values(DirectionOfApplicationOnSP.values));
}
