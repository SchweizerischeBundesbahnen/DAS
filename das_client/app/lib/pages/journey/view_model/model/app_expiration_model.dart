sealed class AppExpirationModel {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppExpirationModel && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'AppExpirationModel{}';
  }
}

class Expired extends AppExpirationModel {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is Expired && runtimeType == other.runtimeType;

  @override
  int get hashCode => super.hashCode;
}

class ExpirySoon extends AppExpirationModel {
  ExpirySoon({
    required this.expiryDate,
    required this.userDismissedDialog,
  });

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
  final DateTime expiryDate;
  final bool userDismissedDialog;
}

class Valid extends AppExpirationModel {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is Valid && runtimeType == other.runtimeType;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return 'Valid{}';
  }
}
