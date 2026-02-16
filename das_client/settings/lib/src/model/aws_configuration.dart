class AwsConfiguration {
  AwsConfiguration({
    required this.bucketUrl,
    required this.accessKey,
    required this.accessSecret,
    this.region = 'eu-central-1',
  });

  final String bucketUrl;
  final String accessKey;
  final String accessSecret;
  final String region;
}
