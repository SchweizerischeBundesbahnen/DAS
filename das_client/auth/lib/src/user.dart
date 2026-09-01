import 'package:auth/src/role.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class const User({
  required final String userId,
  required final List<Role> roles,
  final String? displayName,
  final String? tid,
});
