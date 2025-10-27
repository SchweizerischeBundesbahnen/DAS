package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record Preload(
    @Schema(description = "S3 bucket url")
    String bucketUrl,
    @Schema(description = "Read-only S3 user access key")
    String accessKey,
    @Schema(description = "Read-only S3 user access secret")
    String accessSecret
) {

}
