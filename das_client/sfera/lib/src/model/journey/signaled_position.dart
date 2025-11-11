/// The train position received from TMS VAD.
class SignaledPosition {
  SignaledPosition({required this.order});

  final int order;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is SignaledPosition && order == other.order);

  @override
  int get hashCode => order.hashCode;

  @override
  String toString() {
    return 'SignaledPosition{order: $order}';
  }
}
