import 'package:collection/collection.dart';
import 'package:sfera/src/model/journey/contact.dart';

class RadioContactList implements Comparable {
  RadioContactList({
    required this.order,
    required this.endOrder,
    required Iterable<Contact> contacts,
  }) : mainContacts = contacts.whereType<MainContact>(),
       selectiveContacts = contacts.whereType<SelectiveContact>();

  final int order;
  final int endOrder;
  final Iterable<MainContact> mainContacts;
  final Iterable<SelectiveContact> selectiveContacts;

  @override
  int compareTo(other) {
    if (other is! RadioContactList) return -1;
    return order.compareTo(other.order);
  }

  String? get mainContactsIdentifier =>
      mainContacts.isNotEmpty ? mainContacts.map((c) => c.contactIdentifier).take(2).join(' ') : null;

  bool get isSimCorridor => order != endOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioContactList &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          endOrder == other.endOrder &&
          IterableEquality().equals(mainContacts, other.mainContacts) &&
          IterableEquality().equals(selectiveContacts, other.selectiveContacts);

  @override
  int get hashCode =>
      order.hashCode ^
      endOrder.hashCode ^
      IterableEquality().hash(mainContacts) ^
      IterableEquality().hash(selectiveContacts);

  @override
  String toString() {
    return 'RadioContactList{order: $order, endOrder: $endOrder, mainContacts: $mainContacts, selectiveContacts: $selectiveContacts}';
  }
}

extension RadioContactListExtension on Iterable<RadioContactList> {
  /// Returns last RadioContactList that has lower ordering than given [order].
  RadioContactList? lastBefore(int order) {
    final sortedList = toList()..sort();
    return sortedList.reversed.firstWhereOrNull((contactList) => contactList.order <= order);
  }
}
