import 'package:sfera/src/model/modification.dart';

abstract class AcknowledgedModificationRepository {
  const AcknowledgedModificationRepository._();

  Stream<Set<Modification>> get acknowledgedModifications;

  Future<void> insert(Modification modification);

  Future<void> delete(Modification modification);
}
