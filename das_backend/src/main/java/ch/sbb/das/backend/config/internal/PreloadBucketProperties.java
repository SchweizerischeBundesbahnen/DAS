package ch.sbb.das.backend.config.internal;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "preload.bucket")
record PreloadBucketProperties(String url, String region, Credentials readOnly) {

    record Credentials(String accessKeyId, String secretAccessKey) {
    }
}
