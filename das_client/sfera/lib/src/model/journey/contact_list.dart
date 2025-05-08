import 'package:collection/collection.dart';
import 'package:sfera/src/model/journey/contact.dart';

class RadioContactList implements Comparable {
  RadioContactList({required this.order, required Iterable<Contact> contacts})
      : mainContacts = contacts.whereType<MainContact>(),
        selectiveContacts = contacts.whereType<SelectiveContact>();

  final int order;
  final Iterable<Contact> mainContacts;
  final Iterable<Contact> selectiveContacts;

  @override
  int compareTo(other) {
    if (other is! RadioContactList) return -1;
    return order.compareTo(other.order);
  }

  String? get mainContactsIdentifier =>
      mainContacts.isNotEmpty ? mainContacts.map((c) => c.contactIdentifier).take(2).join(' ') : null;
}

extension RadioContactListExtension on Iterable<RadioContactList> {
  /// Returns last RadioContactList that has lower ordering than given [order].
  RadioContactList? lastLowerThan(int order) {
    final sortedList = toList()..sort();
    return sortedList.reversed.firstWhereOrNull((contactList) => contactList.order <= order);
  }
}
