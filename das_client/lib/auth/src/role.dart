import 'package:collection/collection.dart';

enum Role {
  admin('admin'),
  ruAdmin('ru_admin'),
  observer('observer'),
  driver('driver');

  final String name;

  const Role(this.name);

  static Role? fromName(String name) {
    return Role.values.where((element) => element.name == name).firstOrNull;
  }
}
