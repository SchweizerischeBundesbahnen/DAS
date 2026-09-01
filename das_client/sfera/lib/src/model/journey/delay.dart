class const Delay({required final Duration value, required final String location}) {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delay && runtimeType == other.runtimeType && value == other.value && location == other.location;

  @override
  int get hashCode => value.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'Delay{value: $value, location: $location}';
  }
}
