import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';
import 'package:sfera/src/model/journey/train_series.dart';

class TcFeaturesDto extends SferaXmlElementDto {
  static const String elementType = 'TC_Features';

  TcFeaturesDto({super.type = elementType, super.attributes, super.children, super.value});

  int? get brakedWeightPercentage => ParseUtils.tryParseInt(attributes['brakedWeightPercentage']);

  TrainSeries? get trainCategoryCode => TrainSeries.fromOptional(attributes['trainCategoryCode']);
}
