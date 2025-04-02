import 'package:das_client/model/journey/contact.dart';

class ContactList {
  ContactList({required this.order, required Iterable<Contact> contacts})
      : mainContacts = contacts.whereType<MainContact>(),
        selectiveContacts = contacts.whereType<SelectiveContact>();

  final int order;
  final Iterable<Contact> mainContacts;
  final Iterable<Contact> selectiveContacts;
}
