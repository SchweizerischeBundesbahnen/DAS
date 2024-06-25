import 'package:collection/collection.dart';
import 'package:das_client/auth/token_spec.dart';

class TokenSpecProvider {
  const TokenSpecProvider(this._specs);

  final List<TokenSpec> _specs;

  operator [](int i) => _specs[i];

  int get length => _specs.length;

  List<TokenSpec> get all => List.from(_specs);

  TokenSpec get first => _specs.first;

  TokenSpec? getById(String? id) {
    if (id == null) {
      return null;
    }
    for (final spec in _specs) {
      if (spec.id == id) {
        return spec;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenSpecProvider &&
        ListEquality().equals(other._specs, _specs);
  }

  @override
  int get hashCode {
    return Object.hashAll(_specs);
  }
}
