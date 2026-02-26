import 'package:auth/src/role.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class User {
  const User({required this.userId, required this.roles, this.displayName, this.tid});

  final String userId;
  final String? displayName;
  final List<Role> roles;
  final String? tid;
}
