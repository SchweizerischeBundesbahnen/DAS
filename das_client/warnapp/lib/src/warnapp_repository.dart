abstract class WarnappRepository {
  const WarnappRepository._();

  bool get isEnabled;

  void enable();

  void disable();

  Stream<void> get haltEventStream;

  Stream<void> get abfahrtEventStream;
}
