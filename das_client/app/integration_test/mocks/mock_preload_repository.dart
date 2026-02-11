import 'package:preload/component.dart';
import 'package:settings/component.dart';

class MockPreloadRepository implements PreloadRepository {
  MockPreloadRepository();

  @override
  void updateConfiguration(AwsConfiguration awsConfiguration) {}

  @override
  void triggerPreload() {}

  @override
  Stream<PreloadDetails> get preloadDetails => Stream.empty(broadcast: true);

  @override
  void dispose() {}
}
