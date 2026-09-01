import 'package:sfera/component.dart';

class RadioChannelModel({
  final CommunicationNetworkType? networkType,
  final RadioContactList? _radioContacts,
  final ServicePoint? lastServicePoint,
}) {
  String? get mainContactsIdentifier =>
      _mainContacts.isNotEmpty ? _mainContacts.map((c) => c.contactIdentifier).take(2).join(' ') : null;

  bool get showDotIndicator =>
      _radioContacts != null && (_radioContacts.mainContacts.length > 1 || _radioContacts.selectiveContacts.isNotEmpty);

  Iterable<MainContact> get _mainContacts => _radioContacts?.mainContacts ?? [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioChannelModel &&
          runtimeType == other.runtimeType &&
          networkType == other.networkType &&
          lastServicePoint == other.lastServicePoint &&
          _radioContacts == other._radioContacts;

  @override
  int get hashCode => networkType.hashCode ^ lastServicePoint.hashCode ^ _radioContacts.hashCode;

  @override
  String toString() {
    return 'RadioChannelModel{networkType: $networkType, lastServicePoint: $lastServicePoint, radioContacts: $_radioContacts}';
  }
}
