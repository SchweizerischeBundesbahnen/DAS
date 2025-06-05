class AbfahrtDetectionAlgorithmusProperties {
  final double berechnungsZeit;
  final int lengthForInitialization;

  final int slowWindowLength;
  final int fastWindowLength;

  // Algo3
  final int haltDelayCount;
  final double maxDistance;

  // Algo5
  final int integratorWindowLength;
  final double hystereseAbfahrt;
  final double hystereseHalt;
  final double hystereseHandbewegungPositiv;
  final double hystereseHandbewegungNegativ;
  final int hystereseHandbewegungAnzahlNegativ;
  final int handbewegungWindowLength;

  // Algo7
  final int peakDetectorWindowLength;
  final int peakDetectorBorderLength;
  final double peakDetectorDifferenzMittelwert;
  final double peakDetectorSchwelle;
  final double peakDetectorSchwelleBorder;
  final int peakDetectorDelay;

  final int abfahrtDetektorLength;
  final int abfahrtDetektorLaengeHalt;
  final double abfahrtDetektorSchwelleFahrt;
  final double abfahrtDetektorSchwelleQuiet;

  final int haltDetektorLength;
  final int haltDetektorLaengeHalt;
  final double haltDetektorSchwelleHalt;
  final double haltDetektorSchwelleQuiet;

  final int ruheDetektionLangAnzahlPositiv;
  final double ruheDetektionLangSchwellePositiv;
  final int ruheDetektionLangAnzahlNegativ;
  final double ruheDetektionLangSchwelleNegativ;

  final int ruheDetektionKurzAnzahlPositiv;
  final double ruheDetektionKurzSchwellePositiv;
  final int ruheDetektionKurzAnzahlNegativ;
  final double ruheDetektionKurzSchwelleNegativ;

  // Algo11
  final int slowIntegratorWindowLength;
  final int slowAbfahrtDetektorLength;
  final int slowAbfahrtDetektorLaengeHalt;
  final double slowAbfahrtDetektorSchwelleFahrt;
  final double slowAbfahrtDetektorSchwelleQuiet;

  final int gravitationIntegratorWindowLength;
  final int gravitationHystereseRotationAnzahlPositiv;
  final double gravitationHystereseRotationSchwellePositiv;
  final int gravitationHystereseRotationAnzahlNegativ;
  final double gravitationHystereseRotationSchwelleNegativ;
  final int gravitationAbfahrtDetektorLength;
  final int gravitationAbfahrtDetektorLaengeHalt;
  final double gravitationAbfahrtDetektorSchwelleFahrt;
  final double gravitationAbfahrtDetektorSchwelleQuiet;
  final int gravitationHaltDetektorLength;
  final int gravitationHaltDetektorLaengeHalt;
  final double gravitationHaltDetektorSchwelleHalt;
  final double gravitationHaltDetektorSchwelleQuiet;

  final double hystereseHandbewegung2Positiv;
  final double hystereseHandbewegung2Negativ;
  final int hystereseHandbewegung2AnzahlNegativ;
  final int touchDelay;

  // Algo12
  final int hystereseFahrtDeltaLength;
  final double hystereseFahrtDeltaSchwelle;
  final int hystereseFahrtDeltaAnzahlUeberSchwelle;

  // Algo13
  final double hystereseFahrtLocationSchwelleSpeed;
  final int hystereseFahrtLocationGueltigkeitsDauer;

  // Algo14
  final int lageaenderungWindowLength;
  final double lageaenderungSchwelle;
  final int lageaenderungDelay;
  final int lageaenderungOrNachAnd;

  // Algo15
  final int speedNormalizerGueltigkeitsDauer;

  final int locationAbfahrtDetektorLength;
  final int locationAbfahrtDetektorLaengeHalt;
  final double locationAbfahrtDetektorSchwelleFahrt;

  final int slowLocationAbfahrtDetektorLength;
  final int slowLocationAbfahrtDetektorLaengeHalt;
  final double slowLocationAbfahrtDetektorSchwelleFahrt;

  final int locationHaltDetektorLength;
  final double locationHaltDetektorSchwelleMin;
  final double locationHaltDetektorSchwelleMax;

  final int minimaleAnzahlZwischenZweiAbfahrten;

  AbfahrtDetectionAlgorithmusProperties({
    required this.berechnungsZeit,
    required this.lengthForInitialization,
    required this.slowWindowLength,
    required this.fastWindowLength,
    required this.haltDelayCount,
    required this.maxDistance,
    required this.integratorWindowLength,
    required this.hystereseAbfahrt,
    required this.hystereseHalt,
    required this.hystereseHandbewegungPositiv,
    required this.hystereseHandbewegungNegativ,
    required this.hystereseHandbewegungAnzahlNegativ,
    required this.handbewegungWindowLength,
    required this.peakDetectorWindowLength,
    required this.peakDetectorBorderLength,
    required this.peakDetectorDifferenzMittelwert,
    required this.peakDetectorSchwelle,
    required this.peakDetectorSchwelleBorder,
    required this.peakDetectorDelay,
    required this.abfahrtDetektorLength,
    required this.abfahrtDetektorLaengeHalt,
    required this.abfahrtDetektorSchwelleFahrt,
    required this.abfahrtDetektorSchwelleQuiet,
    required this.haltDetektorLength,
    required this.haltDetektorLaengeHalt,
    required this.haltDetektorSchwelleHalt,
    required this.haltDetektorSchwelleQuiet,
    required this.ruheDetektionLangAnzahlPositiv,
    required this.ruheDetektionLangSchwellePositiv,
    required this.ruheDetektionLangAnzahlNegativ,
    required this.ruheDetektionLangSchwelleNegativ,
    required this.ruheDetektionKurzAnzahlPositiv,
    required this.ruheDetektionKurzSchwellePositiv,
    required this.ruheDetektionKurzAnzahlNegativ,
    required this.ruheDetektionKurzSchwelleNegativ,
    required this.slowIntegratorWindowLength,
    required this.slowAbfahrtDetektorLength,
    required this.slowAbfahrtDetektorLaengeHalt,
    required this.slowAbfahrtDetektorSchwelleFahrt,
    required this.slowAbfahrtDetektorSchwelleQuiet,
    required this.gravitationIntegratorWindowLength,
    required this.gravitationHystereseRotationAnzahlPositiv,
    required this.gravitationHystereseRotationSchwellePositiv,
    required this.gravitationHystereseRotationAnzahlNegativ,
    required this.gravitationHystereseRotationSchwelleNegativ,
    required this.gravitationAbfahrtDetektorLength,
    required this.gravitationAbfahrtDetektorLaengeHalt,
    required this.gravitationAbfahrtDetektorSchwelleFahrt,
    required this.gravitationAbfahrtDetektorSchwelleQuiet,
    required this.gravitationHaltDetektorLength,
    required this.gravitationHaltDetektorLaengeHalt,
    required this.gravitationHaltDetektorSchwelleHalt,
    required this.gravitationHaltDetektorSchwelleQuiet,
    required this.hystereseHandbewegung2Positiv,
    required this.hystereseHandbewegung2Negativ,
    required this.hystereseHandbewegung2AnzahlNegativ,
    required this.touchDelay,
    required this.hystereseFahrtDeltaLength,
    required this.hystereseFahrtDeltaSchwelle,
    required this.hystereseFahrtDeltaAnzahlUeberSchwelle,
    required this.hystereseFahrtLocationSchwelleSpeed,
    required this.hystereseFahrtLocationGueltigkeitsDauer,
    required this.lageaenderungWindowLength,
    required this.lageaenderungSchwelle,
    required this.lageaenderungDelay,
    required this.lageaenderungOrNachAnd,
    required this.speedNormalizerGueltigkeitsDauer,
    required this.locationAbfahrtDetektorLength,
    required this.locationAbfahrtDetektorLaengeHalt,
    required this.locationAbfahrtDetektorSchwelleFahrt,
    required this.slowLocationAbfahrtDetektorLength,
    required this.slowLocationAbfahrtDetektorLaengeHalt,
    required this.slowLocationAbfahrtDetektorSchwelleFahrt,
    required this.locationHaltDetektorLength,
    required this.locationHaltDetektorSchwelleMin,
    required this.locationHaltDetektorSchwelleMax,
    required this.minimaleAnzahlZwischenZweiAbfahrten,
  });

  factory AbfahrtDetectionAlgorithmusProperties.defaultProperties() {
    return AbfahrtDetectionAlgorithmusProperties(
      berechnungsZeit: 2,
      lengthForInitialization: 500,
      slowWindowLength: 500,
      fastWindowLength: 100,
      haltDelayCount: 500,
      maxDistance: 0.005,
      integratorWindowLength: 250,
      hystereseAbfahrt: 1.75,
      hystereseHalt: 0.55,
      hystereseHandbewegungPositiv: 0.5,
      hystereseHandbewegungNegativ: 0.1,
      hystereseHandbewegungAnzahlNegativ: 25,
      handbewegungWindowLength: 25,
      peakDetectorWindowLength: 100,
      peakDetectorBorderLength: 25,
      peakDetectorDifferenzMittelwert: 0.008,
      peakDetectorSchwelle: 0.1,
      peakDetectorSchwelleBorder: 0.05,
      peakDetectorDelay: 25,
      abfahrtDetektorLength: 500,
      abfahrtDetektorLaengeHalt: 250,
      abfahrtDetektorSchwelleFahrt: 0.03,
      abfahrtDetektorSchwelleQuiet: 0.002,
      haltDetektorLength: 500,
      haltDetektorLaengeHalt: 250,
      haltDetektorSchwelleHalt: -0.04,
      haltDetektorSchwelleQuiet: 0.002,
      ruheDetektionLangAnzahlPositiv: 0,
      ruheDetektionLangSchwellePositiv: 0.0025,
      ruheDetektionLangAnzahlNegativ: 1250,
      ruheDetektionLangSchwelleNegativ: 0.0025,
      ruheDetektionKurzAnzahlPositiv: 0,
      ruheDetektionKurzSchwellePositiv: 0.0015,
      ruheDetektionKurzAnzahlNegativ: 500,
      ruheDetektionKurzSchwelleNegativ: 0.0015,
      slowIntegratorWindowLength: 1000,
      slowAbfahrtDetektorLength: 1500,
      slowAbfahrtDetektorLaengeHalt: 1000,
      slowAbfahrtDetektorSchwelleFahrt: 3.5,
      slowAbfahrtDetektorSchwelleQuiet: 0.1,
      gravitationIntegratorWindowLength: 250,
      gravitationHystereseRotationAnzahlPositiv: 0,
      gravitationHystereseRotationSchwellePositiv: 1.25,
      gravitationHystereseRotationAnzahlNegativ: 25,
      gravitationHystereseRotationSchwelleNegativ: 0.1,
      gravitationAbfahrtDetektorLength: 500,
      gravitationAbfahrtDetektorLaengeHalt: 250,
      gravitationAbfahrtDetektorSchwelleFahrt: 999,
      gravitationAbfahrtDetektorSchwelleQuiet: 0.0025,
      gravitationHaltDetektorLength: 500,
      gravitationHaltDetektorLaengeHalt: 250,
      gravitationHaltDetektorSchwelleHalt: -0.04,
      gravitationHaltDetektorSchwelleQuiet: 0.0025,
      hystereseHandbewegung2Positiv: 1.25,
      hystereseHandbewegung2Negativ: 0.1,
      hystereseHandbewegung2AnzahlNegativ: 250,
      touchDelay: 100,
      hystereseFahrtDeltaLength: 3000,
      hystereseFahrtDeltaSchwelle: 0.002,
      hystereseFahrtDeltaAnzahlUeberSchwelle: 2000,
      hystereseFahrtLocationGueltigkeitsDauer: 100,
      hystereseFahrtLocationSchwelleSpeed: 3.0,
      lageaenderungWindowLength: 5,
      lageaenderungSchwelle: 0.2,
      lageaenderungDelay: 100,
      lageaenderungOrNachAnd: 2,
      speedNormalizerGueltigkeitsDauer: 150,
      locationAbfahrtDetektorLength: 500,
      locationAbfahrtDetektorLaengeHalt: 250,
      locationAbfahrtDetektorSchwelleFahrt: 2.0,
      slowLocationAbfahrtDetektorLength: 1000,
      slowLocationAbfahrtDetektorLaengeHalt: 250,
      slowLocationAbfahrtDetektorSchwelleFahrt: 200,
      locationHaltDetektorLength: 500,
      locationHaltDetektorSchwelleMin: 0.01,
      locationHaltDetektorSchwelleMax: 2.0,
      minimaleAnzahlZwischenZweiAbfahrten: 750,
    );
  }
}
