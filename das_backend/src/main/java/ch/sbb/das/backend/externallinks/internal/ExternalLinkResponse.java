package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

public record ExternalLinkResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<ExternalLink> data) implements ApiResponse<ExternalLink> {

    public ExternalLinkResponse(ExternalLink externalLink) {
        this(List.of(externalLink));
    }
}
