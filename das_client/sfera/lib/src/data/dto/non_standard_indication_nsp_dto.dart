import 'package:sfera/src/data/dto/enums/train_run_type_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/train_run_type_nsp_dto.dart';

class NonStandardIndicationNspDto extends JpContextInformationNspDto {
  static const String elementName = 'nonStandardIndication';

  NonStandardIndicationNspDto({super.type, super.attributes, super.children, super.value});

  TrainRunTypeDto? get trainRunType => children.whereType<TrainRunTypeNspDto>().firstOrNull?.trainRunType;
}
