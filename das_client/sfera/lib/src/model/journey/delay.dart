class Delay {
  Delay({required this.value, required this.location});

  final Duration value;
  final String location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delay && runtimeType == other.runtimeType && value == other.value && location == other.location;

  @override
  int get hashCode => value.hashCode ^ location.hashCode;
}
