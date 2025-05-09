import 'package:sfera/src/data/dto/network_specific_point_dto.dart';

class WhistleNetworkSpecificPointDto extends NetworkSpecificPointDto {
  static const String elementName = 'whistle';

  WhistleNetworkSpecificPointDto({super.type, super.attributes, super.children, super.value});
}
