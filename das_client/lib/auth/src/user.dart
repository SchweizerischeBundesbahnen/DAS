import 'package:das_client/auth/src/role.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class User {
  const User({
    required this.name,
    required this.roles
  }) ;

  final String name;
  final List<Role> roles;
}
