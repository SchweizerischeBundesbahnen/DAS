import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class const TokenSpec({
  required final String id,
  required final String displayName,
  required final List<String> scopes,
}) {
  static const String defaultTokenId = 'T1';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenSpec &&
        other.id == id &&
        other.displayName == displayName &&
        const ListEquality().equals(other.scopes, scopes);
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
