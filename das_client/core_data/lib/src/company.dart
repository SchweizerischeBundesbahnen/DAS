class Company {
  const Company({
    required this.code,
    required this.shortName,
  });

  final String code;
  final String shortName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company && runtimeType == other.runtimeType && code == other.code && shortName == other.shortName;

  @override
  int get hashCode => Object.hash(code, shortName);

  @override
  String toString() {
    return 'Company{code: $code, shortName: $shortName}';
  }
}
