import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/util/util.dart';

class TcFeatures extends SferaXmlElement {
  static const String elementType = 'TC_Features';

  TcFeatures({super.type = elementType, super.attributes, super.children, super.value});

  int? get brakedWeightPercentage => Util.tryParseInt(attributes['brakedWeightPercentage']);

  TrainSeries? get trainCategoryCode => TrainSeries.fromOptional(attributes['trainCategoryCode']);
}
