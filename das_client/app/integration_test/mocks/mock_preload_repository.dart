import 'package:preload/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';

class MockPreloadRepository implements PreloadRepository {
  final preloadDetailsSubject = BehaviorSubject<PreloadDetails>();

  @override
  void updateConfiguration(AwsConfiguration? awsConfiguration) {}

  @override
  void triggerPreload() {}

  @override
  Future<void> stopPreload() async {}

  @override
  Stream<PreloadDetails> get preloadDetails => preloadDetailsSubject.stream;

  @override
  void dispose() {}
}
