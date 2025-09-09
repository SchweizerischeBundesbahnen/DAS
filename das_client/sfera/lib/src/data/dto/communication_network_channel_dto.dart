import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/sp_generic_point_dto.dart';

class CommunicationNetworkChannelDto extends SpGenericPointDto {
  static const String elementType = 'CommunicationNetworkChannel';

  CommunicationNetworkChannelDto({super.type = elementType, super.attributes, super.children, super.value});

  CommunicationNetworkType get communicationNetworkType =>
      attributes['communicationNetworkType'] as CommunicationNetworkType;
}
