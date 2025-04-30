import 'package:app/model/journey/signal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test string factory for signal functions', () {
    // when
    final randomType = SignalFunction.from('random-type');
    final block = SignalFunction.from('block');
    final entry = SignalFunction.from('entry');
    final exit = SignalFunction.from('exit');
    final intermediate = SignalFunction.from('intermediate');
    final laneChange = SignalFunction.from('laneChange');
    final protection = SignalFunction.from('protection');

    // then
    expect(randomType, SignalFunction.unknown);
    expect(block, SignalFunction.block);
    expect(entry, SignalFunction.entry);
    expect(exit, SignalFunction.exit);
    expect(intermediate, SignalFunction.intermediate);
    expect(laneChange, SignalFunction.laneChange);
    expect(protection, SignalFunction.protection);
  });
}
