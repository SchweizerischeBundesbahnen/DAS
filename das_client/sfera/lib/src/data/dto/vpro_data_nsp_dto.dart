import 'package:sfera/src/data/dto/fixed_point_relevance_nsp_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';

class VProDataNspDto extends JpContextInformationNspDto {
  static const String groupNameValue = 'VProData';

  VProDataNspDto({super.type, super.attributes, super.children, super.value});

  NewSpeedNetworkSpecificParameterDto? get newSpeed =>
      children.whereType<NewSpeedNetworkSpecificParameterDto>().firstOrNull;

  bool? get fixedPointRelevance => children.whereType<FixedPointRelevanceNspDto>().firstOrNull?.fixedPointRelevance;
}
