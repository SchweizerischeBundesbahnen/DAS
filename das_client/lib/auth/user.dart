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
  })  : email = email ?? 'null',
        familyName = familyName ?? 'null',
        givenName = givenName ?? 'null',
        name = name ?? 'null',
        picture = picture ?? 'null',
        sub = sub ?? 'null';

  final String email;
  final String familyName;
  final String givenName;
  final String name;
  final String picture;
  final String sub;
}
