import 'package:collection/collection.dart';

enum Role(final String name) {
  admin('admin'),
  ruAdmin('ru_admin'),
  observer('observer'),
  driver('driver');

  static Role? fromName(String name) {
    return Role.values.where((element) => element.name == name.trim().toLowerCase()).firstOrNull;
  }
}
