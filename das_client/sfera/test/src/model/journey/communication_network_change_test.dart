import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/communication_network_change.dart';

main() {
  test('test appliesToOrder of CommunicationNetworkChange list', () {
    // GIVEN
    final networkChanges = [
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 100),
      CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 200),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 300),
    ];

    // WHEN
    final notGiven = networkChanges.appliesToOrder(0);
    final gsmP1 = networkChanges.appliesToOrder(100);
    final gsmP2 = networkChanges.appliesToOrder(150);
    final gsmPSimIgnored = networkChanges.whereNotSim.appliesToOrder(250);
    final gsmR1 = networkChanges.appliesToOrder(300);
    final gsmR2 = networkChanges.appliesToOrder(350);

    // THEN
    expect(notGiven, isNull);
    expect(gsmP1, CommunicationNetworkType.gsmP);
    expect(gsmP2, CommunicationNetworkType.gsmP);
    expect(gsmPSimIgnored, CommunicationNetworkType.gsmP);
    expect(gsmR1, CommunicationNetworkType.gsmR);
    expect(gsmR2, CommunicationNetworkType.gsmR);
  });

  test('test changeAtOrder of CommunicationNetworkChange list', () {
    // GIVEN
    final networkChanges = [
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 100),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 200),
      CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 300),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 400),
    ];

    // WHEN
    final gsmP1 = networkChanges.changeAtOrder(100);
    final noChange1 = networkChanges.changeAtOrder(200);
    final gsmPSimIgnored = networkChanges.changeAtOrder(300);
    final gsmR1 = networkChanges.changeAtOrder(400);
    final notGiven = networkChanges.changeAtOrder(500);

    // THEN
    expect(gsmP1, CommunicationNetworkType.gsmP);
    expect(noChange1, isNull);
    expect(gsmPSimIgnored, isNull);
    expect(gsmR1, CommunicationNetworkType.gsmR);
    expect(notGiven, isNull);
  });

  test('whereNotSim_whenHasNoSim_shouldNotChangeList', () {
    // GIVEN
    final networkChanges = [
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 100),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 200),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 300),
    ];

    // WHEN
    final actual = networkChanges.whereNotSim.toList();

    // THEN
    expect(ListEquality().equals(networkChanges, actual), true, reason: 'Expected lists to be equal');
  });

  test('whereNotSim_whenHasSim_shouldRemoveSimEntries', () {
    // GIVEN
    final networkChanges = [
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 100),
      CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 200),
      CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 300),
    ];
    final expected = networkChanges.where((change) => change.type != CommunicationNetworkType.sim).toList();

    // WHEN
    final actual = networkChanges.whereNotSim.toList();

    // THEN
    expect(ListEquality().equals(expected, actual), true, reason: 'Expected lists to be equal');
  });
}
