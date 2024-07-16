import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class TokenSpec {
  static const String defaultTokenId = "T1";

  const TokenSpec({
    required this.id,
    required this.displayName,
    required this.scopes,
  });

  final String id;
  final String displayName;
  final List<String> scopes;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenSpec &&
        other.id == id &&
        other.displayName == displayName &&
        ListEquality().equals(other.scopes, scopes);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      Object.hashAll(scopes),
    );
  }
}
