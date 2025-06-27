class Delay {
  Delay({required this.delay, required this.location});
  final Duration delay;
  final String location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delay && runtimeType == other.runtimeType && delay == other.delay && location == other.location;

  @override
  int get hashCode => delay.hashCode ^ location.hashCode;
}
