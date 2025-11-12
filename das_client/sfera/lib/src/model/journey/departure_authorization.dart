import 'package:meta/meta.dart';

enum DepartureAuthorizationType { sms, dispatcher }

@sealed
@immutable
class DepartureAuthorization {
  const DepartureAuthorization({
    required this.types,
    String? originalText,
  }) : _originalText = originalText;

  final List<DepartureAuthorizationType> types;
  final String? _originalText;

  bool get hasDispatcherAuth => types.contains(DepartureAuthorizationType.dispatcher);

  bool get hasSmsAuth => types.contains(DepartureAuthorizationType.sms);

  String? get text {
    final prefix = hasDispatcherAuth ? '*' : null;

    if (_originalText == null) return prefix;

    final body = _originalText.replaceLineBreaksWithSpace();
    return prefix == null ? body : '$prefix $body';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartureAuthorization &&
          runtimeType == other.runtimeType &&
          types == other.types &&
          _originalText == other._originalText;

  @override
  int get hashCode => Object.hash(types, _originalText);

  @override
  String toString() {
    return 'DepartureAuthorization{types: $types, text: $text}';
  }
}

// extensions

extension _StringExtension on String {
  String replaceLineBreaksWithSpace() {
    final pattern = RegExp(r'(\r\n|\r|\n|<br\s*/?>)', multiLine: true);
    return replaceAll(pattern, ' ');
  }
}
