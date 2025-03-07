import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final gsmPSimIgnored = networkChanges.appliesToOrder(250);
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
}
