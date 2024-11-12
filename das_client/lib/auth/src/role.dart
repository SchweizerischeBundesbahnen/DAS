import 'package:collection/collection.dart';

enum Role {
  admin('admin'),
  evuAdmin('evu_admin'),
  beobachter('beobachter'),
  lokpersonal('lokpersonal');

  final String name;

  const Role(this.name);

  static Role? fromName(String name) {
    return Role.values.where((element) => element.name == name).firstOrNull;
  }
}
