import 'dart:convert';

import 'package:app_links_x/src/train_journey/train_journey_data_dto.dart';
import 'package:app_links_x/src/train_journey/train_journey_dto.dart';
import 'package:app_links_x/src/train_journey/train_journey_link_data.dart';

class TrainJourneyParser {
  const TrainJourneyParser._();

  static const String page = 'train-journey';

  static List<TrainJourneyLinkData> parse(Uri uri) {
    final decodedData = jsonDecode(_extractDataParam(uri));

    if (decodedData is! Map<String, dynamic>) {
      throw FormatException('data must be a JSON object');
    }

    final trainJourneyDto = TrainJourneyDataDto.fromJson(decodedData);
    return trainJourneyDto.journeys.map((dto) => dto.toLinkData()).toList();
  }

  static String _extractDataParam(Uri uri) {
    final parameters = uri.queryParameters.normalizeParameters();
    final data = parameters['data'];
    if (data == null || data.trim().isEmpty) {
      throw FormatException('Missing required "data" query parameter');
    }
    return data.trim();
  }
}

extension _QueryParametersExtension on Map<String, String> {
  Map<String, String> normalizeParameters() {
    final map = <String, String>{};
    forEach((k, v) => map[k.toLowerCase()] = v);
    return map;
  }
}
