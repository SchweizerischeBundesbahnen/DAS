class AwsConfiguration({
  required final String bucketUrl,
  required final String accessKey,
  required final String accessSecret,
  required final String region,
}) {
  AwsConfiguration.empty() : this(bucketUrl: '', accessKey: '', accessSecret: '', region: '');

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
