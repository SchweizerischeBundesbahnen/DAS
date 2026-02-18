import 'package:sfera/src/data/dto/end_destination_change_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_to_pass_or_pass_to_stop_nsp_dto.dart';
import 'package:sfera/src/data/dto/tms_data_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_nsp_dto.dart';

class GeneralJpInformationDto extends SferaXmlElementDto {
  static const String elementType = 'General_JP_Information';

  GeneralJpInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  TmsDataNspDto? get tmsDataNsp => children.whereType<TmsDataNspDto>().firstOrNull;

  Iterable<StopToPassOrPassToStopNspDto> get stopToPassOrPassToStopNsps =>
      children.whereType<StopToPassOrPassToStopNspDto>();

  Iterable<EndDestinationChangeNspDto> get endDestinationChangeNsps => children.whereType<EndDestinationChangeNspDto>();

  Iterable<TrainRunReroutingNspDto> get trainRunReroutingNsps => children.whereType<TrainRunReroutingNspDto>();
}
