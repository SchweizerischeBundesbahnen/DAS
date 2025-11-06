sealed class Contact {
  const Contact({required this.contactIdentifier, this.contactRole});

  final String contactIdentifier;
  final String? contactRole;
}

class MainContact extends Contact {
  MainContact({required super.contactIdentifier, super.contactRole});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainContact &&
          runtimeType == other.runtimeType &&
          contactIdentifier == other.contactIdentifier &&
          contactRole == other.contactRole;

  @override
  int get hashCode => contactIdentifier.hashCode ^ contactRole.hashCode;

  @override
  String toString() {
    return 'MainContact{contactIdentifier: $contactIdentifier, contactRole: $contactRole}';
  }
}

class SelectiveContact extends Contact {
  SelectiveContact({required super.contactIdentifier, super.contactRole});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectiveContact &&
          runtimeType == other.runtimeType &&
          contactIdentifier == other.contactIdentifier &&
          contactRole == other.contactRole;

  @override
  int get hashCode => contactIdentifier.hashCode ^ contactRole.hashCode;

  @override
  String toString() {
    return 'SelectiveContact{contactIdentifier: $contactIdentifier, contactRole: $contactRole}';
  }
}
