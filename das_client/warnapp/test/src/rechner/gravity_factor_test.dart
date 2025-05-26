import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/gravity_factor.dart';

late GravityFactor gravityFactor;

void main() {
  group('GravityFactor Tests', () {
    test('Uebergaenge Von Init Mit Anzahl Updates Seit Statuswechsel 1', () {
      execute(
          GravityFactorStatusType.init,
          1,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.init)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.init)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.init)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Init Mit Anzahl Updates Seit Statuswechsel 2', () {
      execute(
          GravityFactorStatusType.init,
          2,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.halt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Fahrt Undefiniert', () {
      execute(
          GravityFactorStatusType.fahrtUndefiniert,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.haltAnfang)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Halt Anfang', () {
      execute(
          GravityFactorStatusType.haltAnfang,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.halt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Halt', () {
      execute(
          GravityFactorStatusType.halt,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.halt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Fahrt', () {
      execute(
          GravityFactorStatusType.fahrt,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.haltAnfang)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Rotation', () {
      execute(
          GravityFactorStatusType.rotation,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotationBeendetImHalt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Rotation Beendet Im Halt Mit Anzahl Updates Seit Statuswechsel 0', () {
      execute(
          GravityFactorStatusType.rotationBeendetImHalt,
          0,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotationBeendetImHalt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Rotation Beendet Im Halt Mit Anzahl Updates Seit Statuswechsel 50', () {
      execute(
          GravityFactorStatusType.rotationBeendetImHalt,
          50,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotationBeendetImHalt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });

    test('Uebergaenge Von Rotation Beendet Im Halt Mit Anzahl Updates Seit Statuswechsel 51', () {
      execute(
          GravityFactorStatusType.rotationBeendetImHalt,
          51,
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.halt)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.fahrtUndefiniert)),
          () => expect(gravityFactor.type, equals(GravityFactorStatusType.rotation)));
    });
  });
}

void execute(GravityFactorStatusType type, int anzahlUpdatesSeitStatuswechsel, Function nonono, Function noyesno,
    Function yesnono, Function yesyesno, Function nonoyes, Function noyesyes, Function yesnoyes, Function yesyesyes) {
  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(false, false, false);
  nonono();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(false, true, false);
  noyesno();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(true, false, false);
  yesnono();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(true, true, false);
  yesyesno();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(false, false, true);
  nonoyes();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(false, true, true);
  noyesyes();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(true, false, true);
  yesnoyes();

  gravityFactor = GravityFactor(type: type);
  gravityFactor.anzahlUpdatesSeitStatuswechsel = anzahlUpdatesSeitStatuswechsel;
  gravityFactor.updateWithFahrt(true, true, true);
  yesyesyes();
}
