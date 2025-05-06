import 'package:sfera/src/model/journey/train_series.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class VelocityDto extends SferaXmlElementDto {
  static const String elementType = 'v';

  VelocityDto({super.type = elementType, super.attributes, super.children, super.value});

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
