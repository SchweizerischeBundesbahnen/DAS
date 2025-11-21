class DecisiveGradient {
  const DecisiveGradient({this.uphill, this.downhill});

  final double? uphill;
  final double? downhill;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DecisiveGradient && uphill == other.uphill && downhill == other.downhill);

  @override
  int get hashCode => Object.hash(uphill, downhill);

  @override
  String toString() {
    return 'DecisiveGradient{uphill: $uphill, downhill: $downhill}';
  }
}
