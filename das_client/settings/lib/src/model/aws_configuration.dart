class AwsConfiguration {
  AwsConfiguration({
    required this.bucketUrl,
    required this.accessKey,
    required this.accessSecret,
    this.region = 'eu-central-1',
  });

  AwsConfiguration.empty() : this(bucketUrl: '', accessKey: '', accessSecret: '');

  final String bucketUrl;
  final String accessKey;
  final String accessSecret;
  final String region;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwsConfiguration &&
          runtimeType == other.runtimeType &&
          bucketUrl == other.bucketUrl &&
          accessKey == other.accessKey &&
          accessSecret == other.accessSecret &&
          region == other.region;

  @override
  int get hashCode => Object.hash(bucketUrl, accessKey, accessSecret, region);
}
