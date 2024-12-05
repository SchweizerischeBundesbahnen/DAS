import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class Velocity extends SferaXmlElement {
  static const String elementType = 'v';

  Velocity({super.type = elementType, super.attributes, super.children, super.value});

  TrainSeries get trainSeries => TrainSeries.from(attributes['trainSeries']!);

  int? get brakeSeries => attributes['brakeSeries'] != null ? int.tryParse(attributes['brakeSeries']!) : null;

  String? get speed => attributes['speed'];

  bool get reduced => attributes['reduced'] != null ? bool.parse(attributes['reduced']!) : false;

  @override
  bool validate() {
    return validateHasAttributeInRange('trainSeries', TrainSeries.values.map((it) => it.name).toList()) &&
        super.validate();
  }
}
