class AppVersionExpiration {
  AppVersionExpiration({required this.expired, this.expiryDate});

  final bool expired;
  final DateTime? expiryDate;

  bool get isExpired => expired || (expiryDate != null && expiryDate!.isAfter(DateTime.now()));
}
