class const Company({required final String code, required final String shortName}) {
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
