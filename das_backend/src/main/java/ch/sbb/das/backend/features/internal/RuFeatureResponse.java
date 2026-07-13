package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.ApiResponse;
import ch.sbb.das.backend.features.RuFeature;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record RuFeatureResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<RuFeature> data) implements ApiResponse<RuFeature> {

    public RuFeatureResponse(RuFeature single) {
        this(List.of(single));
    }
}
