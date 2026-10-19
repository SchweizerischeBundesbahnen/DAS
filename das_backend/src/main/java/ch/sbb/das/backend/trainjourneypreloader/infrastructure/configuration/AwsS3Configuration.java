package ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

@Configuration
@EnableConfigurationProperties(PreloadBucketProperties.class)
public class AwsS3Configuration {

    @Bean
    public S3Client s3Client(PreloadBucketProperties preloadBucketProperties) {
        PreloadBucketProperties.Credentials readWrite = preloadBucketProperties.readWrite();
        AwsBasicCredentials awsCreds = AwsBasicCredentials.create(readWrite.accessKeyId(), readWrite.secretAccessKey());
        return S3Client.builder()
            .region(Region.of(preloadBucketProperties.region()))
            .credentialsProvider(StaticCredentialsProvider.create(awsCreds))
            .build();
    }
}
