import 'package:settings/component.dart';

abstract class PreloadRepository {
  const PreloadRepository._();

  void updateConfiguration(AwsConfiguration awsConfiguration);
}
