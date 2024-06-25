import 'package:meta/meta.dart';

@sealed
@immutable
class User {
  const User({
    String? email,
    String? familyName,
    String? givenName,
    String? name,
    String? picture,
    String? sub,
  })  : this.email = email ?? 'null',
        this.familyName = familyName ?? 'null',
        this.givenName = givenName ?? 'null',
        this.name = name ?? 'null',
        this.picture = picture ?? 'null',
        this.sub = sub ?? 'null';

  final String email;
  final String familyName;
  final String givenName;
  final String name;
  final String picture;
  final String sub;
}
