package ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "preload.bucket")
public record PreloadBucketProperties(String name, String region, Credentials readWrite) {

    public record Credentials(String accessKeyId, String secretAccessKey) {
    }
}
