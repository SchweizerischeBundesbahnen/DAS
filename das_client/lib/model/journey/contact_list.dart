import 'package:das_client/model/journey/contact.dart';

class ContactList {
  ContactList({required this.contacts, required this.order});

  final Iterable<Contact> contacts;
  final int order;
}
