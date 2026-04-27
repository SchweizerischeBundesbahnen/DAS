sealed class AppExpirationModel {
  AppExpirationModel({required this.currentAppVersion});

  final String currentAppVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppExpirationModel && runtimeType == other.runtimeType && currentAppVersion == other.currentAppVersion;

  @override
  int get hashCode => currentAppVersion.hashCode;

  @override
  String toString() {
    return 'AppExpirationModel{currentAppVersion: $currentAppVersion}';
  }
}

class Expired extends AppExpirationModel {
  Expired({required super.currentAppVersion});
}

class ExpirySoon extends AppExpirationModel {
  ExpirySoon({
    required this.expiryDate,
    required this.userDismissedDialog,
    required super.currentAppVersion,
  });

  final DateTime expiryDate;
  final bool userDismissedDialog;

  @override
  String toString() {
    return 'ExpirySoon{expiryDate: $expiryDate, userConfirmed: $userDismissedDialog}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ExpirySoon &&
          runtimeType == other.runtimeType &&
          expiryDate == other.expiryDate &&
          userDismissedDialog == other.userDismissedDialog;

  @override
  int get hashCode => Object.hash(super.hashCode, expiryDate, userDismissedDialog);
}

class Valid extends AppExpirationModel {
  Valid({required super.currentAppVersion});

  @override
  String toString() {
    return 'Valid{}';
  }
}
