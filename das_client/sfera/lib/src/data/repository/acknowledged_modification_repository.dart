import 'package:sfera/src/model/modification.dart';

abstract class const AcknowledgedModificationRepository._() {
  Stream<Set<Modification>> get model;

  Set<Modification> get modelValue;

  Future<void> insert(Modification modification);

  Future<void> delete(Modification modification);

  void dispose();
}
