class AppVersionExpiration {
  AppVersionExpiration({required this.expired, this.expiryDate});

  final bool expired;
  final DateTime? expiryDate;

  bool get isExpired => expired || (expiryDate != null && expiryDate!.isBefore(DateTime.now()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersionExpiration &&
          runtimeType == other.runtimeType &&
          expired == other.expired &&
          expiryDate == other.expiryDate;

  @override
  int get hashCode => Object.hash(expired, expiryDate);
}
