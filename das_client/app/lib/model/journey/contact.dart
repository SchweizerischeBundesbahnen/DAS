sealed class Contact {
  const Contact({required this.contactIdentifier, this.contactRole});

  final String contactIdentifier;
  final String? contactRole;
}

class MainContact extends Contact {
  MainContact({required super.contactIdentifier, super.contactRole});
}

class SelectiveContact extends Contact {
  SelectiveContact({required super.contactIdentifier, super.contactRole});
}
