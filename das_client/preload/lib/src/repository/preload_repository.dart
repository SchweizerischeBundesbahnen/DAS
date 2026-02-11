import 'package:preload/src/model/preload_details.dart';
import 'package:settings/component.dart';

abstract class PreloadRepository {
  const PreloadRepository._();

  void updateConfiguration(AwsConfiguration awsConfiguration);

  void triggerPreload();

  Stream<PreloadDetails> get preloadDetails;

  void dispose();
}
