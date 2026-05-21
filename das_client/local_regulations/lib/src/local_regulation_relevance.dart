import 'package:collection/collection.dart';

/// Describes for what/who the local regulation is relevant
enum LocalRegulationRelevance {
  /// Local regulations for train journeys and shunting manoeuvres
  trainJourneysAndShuntingManoeuvres(abbreviation: 'ZR'),

  /// Local regulations for train journeys
  trainJourneys(abbreviation: 'Z'),

  /// Local regulations for shunting manoeuvres
  shuntingManoeuvres(abbreviation: 'R'),

  /// Local regulations in cross-border traffic
  crossBorderTraffic(abbreviation: 'GV'),

  /// Local regulations for traffic controllers
  trafficControllers(abbreviation: 'Fdl');

  const LocalRegulationRelevance({required this.abbreviation});

  final String abbreviation;

  /// Extracts the relevance from a string that starts with the abbreviation.
  /// Example: "GV Ortsfestes französisches Signal"
  static LocalRegulationRelevance? from(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final firstToken = trimmed.split(RegExp(r'\s+')).first;
    return LocalRegulationRelevance.values.firstWhereOrNull(
      (relevance) => relevance.abbreviation.toLowerCase() == firstToken.toLowerCase(),
    );
  }
}
