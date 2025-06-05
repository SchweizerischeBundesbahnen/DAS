import 'package:intl/intl.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16_properties.dart';
import 'package:warnapp/src/rechner/abfahrt_detector.dart';
import 'package:warnapp/src/rechner/delayed_trigger.dart';
import 'package:warnapp/src/rechner/delta.dart';
import 'package:warnapp/src/rechner/fahrt_hysterese.dart';
import 'package:warnapp/src/rechner/fir_filter.dart';
import 'package:warnapp/src/rechner/gravity_factor.dart';
import 'package:warnapp/src/rechner/halt_detector.dart';
import 'package:warnapp/src/rechner/hysterese.dart';
import 'package:warnapp/src/rechner/integrator.dart';
import 'package:warnapp/src/rechner/lage_aenderung_detector.dart';
import 'package:warnapp/src/rechner/location_abfahrt_detector.dart';
import 'package:warnapp/src/rechner/location_fahrt_hysterese.dart';
import 'package:warnapp/src/rechner/location_halt_detector.dart';
import 'package:warnapp/src/rechner/peak_detector.dart';
import 'package:warnapp/src/rechner/rs_flip_flop.dart';
import 'package:warnapp/src/rechner/signal_keeper_3d.dart';
import 'package:warnapp/src/rechner/speed_normalizer.dart';
import 'package:warnapp/src/rechner/vector_calculator.dart';

class Algorithmus16 {
  final Algorithmus16Properties properties;

  final FIRFilter3D slowFirFilter;
  final FIRFilter3D fastFirFilter;
  final Integrator integrator;
  final Hysterese hystereseHandbewegung;
  final Hysterese hystereseHandbewegung2;

  final FIRFilter3D handbewegungFirFilter;
  final PeakDetector3D peakDetector;
  final DelayedTrigger delayedPeakDetector;
  final DelayedTrigger delayedTouch;
  final double berechnungsZeit;
  final int lengthForInitialization;
  int updatesCount = 0;
  final Delta delta;

  bool wasHalt = true;
  bool wasHaltFlanke = true;

  final AbfahrtDetector abfahrtDetektor;
  final LocationFahrtHysterese fahrtHystereseSpeed;
  final FahrtHysterese fahrtHystereseDelta;
  final DelayedTrigger fahrtHystereseDeltaFlanke;
  final HaltDetector haltDetektor;
  final Hysterese ruheDetektionHystereseLang;
  final Hysterese ruheDetektionHystereseKurz;
  final RSFlipFlop flipFlop;

  final Integrator slowIntegrator;
  final AbfahrtDetector slowAbfahrtDetektor;

  final Hysterese gravitationHystereseRotation;
  final GravityFactor gravitationsFaktor;
  final SignalKeeper3D keeper;
  final Integrator gravitationsIntegrator;
  final AbfahrtDetector gravitationsAbfahrtDetektor;
  final HaltDetector gravitationsHaltDetektor;
  final Delta gravitationsDelta;

  String? abfahrtInfo;
  String softSetInfos = '';
  double lastLongitude = 0.0;
  double lastLatitude = 0.0;

  final LageAenderungDetector3D lageaenderungDetector;
  final DelayedTrigger delayedTriggerLageaenderung;
  final int lageaenderungOrNachAnd;

  final SpeedNormalizer speedNormalizer;
  final LocationAbfahrtDetector locationAbfahrtDetektor;
  final LocationAbfahrtDetector slowLocationAbfahrtDetektor;
  final LocationHaltDetector locationHaltDetektor;

  Algorithmus16({required this.properties})
      : slowFirFilter = FIRFilter3D(properties.slowWindowLength, resetOnFirstUpdate: true),
        fastFirFilter = FIRFilter3D(properties.fastWindowLength, resetOnFirstUpdate: true),
        integrator = Integrator(properties.integratorWindowLength),
        hystereseHandbewegung = Hysterese(
          state: false,
          anzahlPositiv: 0,
          schwellePositiv: properties.hystereseHandbewegungPositiv,
          anzahlNegativ: properties.hystereseHandbewegungAnzahlNegativ,
          schwelleNegativ: properties.hystereseHandbewegungNegativ,
        ),
        hystereseHandbewegung2 = Hysterese(
          state: false,
          anzahlPositiv: 0,
          schwellePositiv: properties.hystereseHandbewegung2Positiv,
          anzahlNegativ: properties.hystereseHandbewegung2AnzahlNegativ,
          schwelleNegativ: properties.hystereseHandbewegung2Negativ,
        ),
        handbewegungFirFilter = FIRFilter3D(properties.handbewegungWindowLength, resetOnFirstUpdate: true),
        peakDetector = PeakDetector3D(
          properties.peakDetectorWindowLength,
          properties.peakDetectorBorderLength,
          properties.peakDetectorDifferenzMittelwert,
          properties.peakDetectorSchwelle,
          properties.peakDetectorSchwelleBorder,
        ),
        delayedPeakDetector = DelayedTrigger(false, 0, properties.peakDetectorDelay),
        delayedTouch = DelayedTrigger(false, 0, properties.touchDelay),
        berechnungsZeit = properties.berechnungsZeit,
        lengthForInitialization = properties.lengthForInitialization,
        delta = Delta(),
        abfahrtDetektor = AbfahrtDetector(
          length: properties.abfahrtDetektorLength,
          laengeHalt: properties.abfahrtDetektorLaengeHalt,
          schwelleFahrt: properties.abfahrtDetektorSchwelleFahrt,
          schwelleQuiet: properties.abfahrtDetektorSchwelleQuiet,
        ),
        fahrtHystereseSpeed = LocationFahrtHysterese(
          properties.hystereseFahrtLocationSchwelleSpeed,
          properties.hystereseFahrtLocationGueltigkeitsDauer,
        ),
        fahrtHystereseDelta = FahrtHysterese(
          properties.hystereseFahrtDeltaLength,
          properties.hystereseFahrtDeltaSchwelle,
          properties.hystereseFahrtDeltaAnzahlUeberSchwelle,
        ),
        fahrtHystereseDeltaFlanke = DelayedTrigger(false, 0, 0),
        haltDetektor = HaltDetector(
          properties.haltDetektorLength,
          properties.haltDetektorLaengeHalt,
          properties.haltDetektorSchwelleHalt,
          properties.haltDetektorSchwelleQuiet,
        ),
        ruheDetektionHystereseLang = Hysterese(
          state: false,
          anzahlPositiv: properties.ruheDetektionLangAnzahlPositiv,
          schwellePositiv: properties.ruheDetektionLangSchwellePositiv,
          anzahlNegativ: properties.ruheDetektionLangAnzahlNegativ,
          schwelleNegativ: properties.ruheDetektionLangSchwelleNegativ,
          absolut: true,
        ),
        ruheDetektionHystereseKurz = Hysterese(
          state: false,
          anzahlPositiv: properties.ruheDetektionKurzAnzahlPositiv,
          schwellePositiv: properties.ruheDetektionKurzSchwellePositiv,
          anzahlNegativ: properties.ruheDetektionKurzAnzahlNegativ,
          schwelleNegativ: properties.ruheDetektionKurzSchwelleNegativ,
          absolut: true,
        ),
        flipFlop = RSFlipFlop(
          5,
          5,
          properties.minimaleAnzahlZwischenZweiAbfahrten,
        ),
        slowIntegrator = Integrator(properties.slowIntegratorWindowLength),
        slowAbfahrtDetektor = AbfahrtDetector(
          length: properties.slowAbfahrtDetektorLength,
          laengeHalt: properties.slowAbfahrtDetektorLaengeHalt,
          schwelleFahrt: properties.slowAbfahrtDetektorSchwelleFahrt,
          schwelleQuiet: properties.slowAbfahrtDetektorSchwelleQuiet,
        ),
        gravitationHystereseRotation = Hysterese(
          state: false,
          anzahlPositiv: properties.gravitationHystereseRotationAnzahlPositiv,
          schwellePositiv: properties.gravitationHystereseRotationSchwellePositiv,
          anzahlNegativ: properties.gravitationHystereseRotationAnzahlNegativ,
          schwelleNegativ: properties.gravitationHystereseRotationSchwelleNegativ,
        ),
        gravitationsFaktor = GravityFactor(),
        keeper = SignalKeeper3D(),
        gravitationsIntegrator = Integrator(properties.gravitationIntegratorWindowLength),
        gravitationsAbfahrtDetektor = AbfahrtDetector(
          length: properties.gravitationAbfahrtDetektorLength,
          laengeHalt: properties.gravitationAbfahrtDetektorLaengeHalt,
          schwelleFahrt: properties.gravitationAbfahrtDetektorSchwelleFahrt,
          schwelleQuiet: properties.gravitationAbfahrtDetektorSchwelleQuiet,
        ),
        gravitationsHaltDetektor = HaltDetector(
          properties.gravitationHaltDetektorLength,
          properties.gravitationHaltDetektorLaengeHalt,
          properties.gravitationHaltDetektorSchwelleHalt,
          properties.gravitationHaltDetektorSchwelleQuiet,
        ),
        gravitationsDelta = Delta(),
        speedNormalizer = SpeedNormalizer(properties.speedNormalizerGueltigkeitsDauer),
        locationAbfahrtDetektor = LocationAbfahrtDetector(
          properties.locationAbfahrtDetektorLength,
          properties.locationAbfahrtDetektorLaengeHalt,
          properties.locationAbfahrtDetektorSchwelleFahrt,
        ),
        slowLocationAbfahrtDetektor = LocationAbfahrtDetector(
          properties.slowLocationAbfahrtDetektorLength,
          properties.slowLocationAbfahrtDetektorLaengeHalt,
          properties.slowLocationAbfahrtDetektorSchwelleFahrt,
        ),
        locationHaltDetektor = LocationHaltDetector(
          properties.locationHaltDetektorLength,
          properties.locationHaltDetektorSchwelleMin,
          properties.locationHaltDetektorSchwelleMax,
        ),
        lageaenderungDetector = LageAenderungDetector3D(
          properties.lageaenderungWindowLength,
          properties.lageaenderungWindowLength,
          properties.lageaenderungSchwelle,
        ),
        delayedTriggerLageaenderung = DelayedTrigger(false, 0, properties.lageaenderungDelay),
        lageaenderungOrNachAnd = properties.lageaenderungOrNachAnd;

  String? get abfahrtInfos => abfahrtInfo;

  bool updateWithAcceleration(
    double accX,
    double accY,
    double accZ,
    double rotX,
    double rotY,
    double rotZ,
    bool touch,
    double speed,
    double timestampSpeed,
    double latitude,
    double longitude,
    double horizontalAccuracy,
  ) {
    if (timestampSpeed > 0.0) {
      lastLatitude = latitude;
      lastLongitude = longitude;
    }

    final lageAenderungDetector = lageaenderungDetector.updateXYZ(accX, accY, accZ);
    final lageAenderung = delayedTriggerLageaenderung.updateWithTrigger(lageAenderungDetector);

    final rotation = (rotX.abs() + rotY.abs() + rotZ.abs());
    final hystHandbewegung = hystereseHandbewegung.update(rotation);
    final hystHandbewegung2 = hystereseHandbewegung2.update(rotation);
    peakDetector.updateXYZ(accX, accY, accZ);
    final peak = delayedPeakDetector.updateWithTrigger(peakDetector.state);
    final delayedTouch = this.delayedTouch.updateWithTrigger(touch);

    final handbewegung =
        hystHandbewegung || hystHandbewegung2 || delayedTouch || peak || (lageAenderung && lageaenderungOrNachAnd == 1);
    final handbewegungUndHaltOderLageAenderung =
        (wasHalt && handbewegung) || (lageAenderung && lageaenderungOrNachAnd == 2);

    handbewegungFirFilter.updateXYZ(accX, accY, accZ);
    if (handbewegungUndHaltOderLageAenderung) {
      slowFirFilter.resetWithXYZ(handbewegungFirFilter.filterX.value, handbewegungFirFilter.filterY.value,
          handbewegungFirFilter.filterZ.value);
      fastFirFilter.resetWithXYZ(handbewegungFirFilter.filterX.value, handbewegungFirFilter.filterY.value,
          handbewegungFirFilter.filterZ.value);
    } else {
      slowFirFilter.updateXYZ(accX, accY, accZ);
      fastFirFilter.updateXYZ(accX, accY, accZ);
    }

    final distance = VectorCalculator.distanceBetween(slowFirFilter, fastFirFilter);
    final deltaValue = delta.updateWithDistance(distance);
    final distanceIntegrated = integrator.updateWithNewSample(deltaValue);

    final gravityDrehung = gravitationHystereseRotation.update(rotation);
    gravitationsFaktor.updateWithFahrt(
        !wasHalt, (gravityDrehung || lageAenderung), handbewegungUndHaltOderLageAenderung);
    final gravityFactor = gravitationsFaktor.factor;
    final gravityDisable = gravitationsFaktor.disabled;
    keeper.updateWithValue(slowFirFilter, gravityFactor);
    final gravityDistance = VectorCalculator.distanceBetween(keeper, fastFirFilter);
    final gravityDelta = gravitationsDelta.updateWithDistance(gravityDistance);
    final gravityDistanceIntegrated =
        gravitationsIntegrator.updateWithNewSample(gravityDelta, disabled: gravityDisable);

    if (wasHaltFlanke) {
      fahrtHystereseDelta.reset(0);
    } else {
      fahrtHystereseDelta.update(distanceIntegrated.abs());
    }

    final normalizedSpeed = speedNormalizer.updateWithSpeed(speed, timestampSpeed);
    final locationAbfahrtDetected =
        locationAbfahrtDetektor.update(normalizedSpeed, disabled: handbewegungUndHaltOderLageAenderung);
    final slowLocationAbfahrtDetected =
        slowLocationAbfahrtDetektor.update(normalizedSpeed, disabled: handbewegungUndHaltOderLageAenderung);
    final locationRuheDetected = locationHaltDetektor.update(normalizedSpeed);

    final gravityAbfahrtDetected =
        gravitationsAbfahrtDetektor.update(gravityDistanceIntegrated, disabled: handbewegungUndHaltOderLageAenderung);
    final gravityHaltDetected = gravitationsHaltDetektor.update(gravityDistanceIntegrated);

    final fahrtDetectedSpeed = fahrtHystereseSpeed.updateWithSpeed(speed, timestampSpeed);
    fahrtHystereseDeltaFlanke.updateWithTrigger(fahrtHystereseDelta.fahrt);
    final fahrtDetectedDelta = fahrtHystereseDeltaFlanke.positiveSchwelleErkannt;

    final abfahrtDetected = abfahrtDetektor.update(distanceIntegrated, disabled: handbewegungUndHaltOderLageAenderung);
    final haltDetected = haltDetektor.update(distanceIntegrated);
    final ruheLangDetected = !ruheDetektionHystereseLang.update(distanceIntegrated);
    final ruheKurzDetected = !ruheDetektionHystereseKurz.update(distanceIntegrated);

    final slowDistanceIntegrated = slowIntegrator.updateWithNewSample(distance);
    final slowAbfahrtDetected =
        slowAbfahrtDetektor.update(slowDistanceIntegrated, disabled: handbewegungUndHaltOderLageAenderung);

    flipFlop.set(
      [
        gravityAbfahrtDetected,
        abfahrtDetected,
        slowAbfahrtDetected,
        locationAbfahrtDetected,
        slowLocationAbfahrtDetected
      ],
      [fahrtDetectedDelta, fahrtDetectedSpeed],
      [gravityHaltDetected, haltDetected, ruheLangDetected, ruheKurzDetected, locationRuheDetected],
    );

    wasHalt = !flipFlop.state;
    wasHaltFlanke = flipFlop.negativeSchwelleErkannt;

    if (flipFlop.softSetErkannt) {
      saveSoftSetInfo(flipFlop.changedSoftSetIndex, lastLatitude, lastLongitude, DateTime.now());
    }

    if (flipFlop.positiveSchwelleErkannt) {
      if (flipFlop.changedSoftSetIndex > 0) {
        abfahrtInfo =
            'FlipFlop Set:${flipFlop.changedSetIndex} SoftSet:${flipFlop.changedSoftSetIndex} ($softSetInfos) Reset:${flipFlop.changedResetIndex}';
      } else {
        abfahrtInfo = 'FlipFlop Set:${flipFlop.changedSetIndex} SoftSet:- Reset:${flipFlop.changedResetIndex}';
      }
      softSetInfos = '';
      flipFlop.changedSetIndex = 0;
      flipFlop.changedSoftSetIndex = 0;
      flipFlop.changedResetIndex = 0;
    } else {
      abfahrtInfo = null;
    }

    bool abfahrt = flipFlop.positiveSchwelleErkannt;

    if (++updatesCount < lengthForInitialization) {
      abfahrt = false;
    }

    return abfahrt;
  }

  bool get isHalt => updatesCount >= lengthForInitialization && !flipFlop.state;

  void reset() {
    updatesCount = 0;
  }

  String info() => 'Algorithmus16 (V1.1)';

  String infoWithConfig() => '${info()} $properties';

  String stringFromCurrentTime(DateTime time) {
    final formatter = DateFormat('HH:mm:ss', 'de_DE');
    return formatter.format(time);
  }

  void saveSoftSetInfo(int changedSoftSetIndex, double latitude, double longitude, DateTime now) {
    // const softSetIndexFahrtHysterese = 1; // unused #defined
    const softSetIndexLocationFahrtHysterese = 2;

    if (softSetInfos.isNotEmpty) {
      softSetInfos += ';';
    }
    if (changedSoftSetIndex == softSetIndexLocationFahrtHysterese) {
      softSetInfos += '$changedSoftSetIndex,${stringFromCurrentTime(now)},$latitude,$longitude';
    } else {
      softSetInfos += '$changedSoftSetIndex,${stringFromCurrentTime(now)}';
    }
  }
}
