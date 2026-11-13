class AccessToken {
  const AccessToken({required this.jwt, required this.expiresAt});

  final String jwt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() => 'AccessToken(expiresAt: $expiresAt)';
}
