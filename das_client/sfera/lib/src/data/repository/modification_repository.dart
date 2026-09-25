import 'package:sfera/component.dart';

abstract class ModificationRepository._() {
  Stream<List<Modification>> get modificationsStream;

  Future<void> insert(Modification modification);

  Future<void> delete(Modification modification);
}
