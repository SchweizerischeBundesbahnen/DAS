package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record InternalRuFeatureResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED)) List<InternalRuFeature> data)
    implements ApiResponse<InternalRuFeature> {

    public InternalRuFeatureResponse(InternalRuFeature single) {
        this(List.of(single));
    }
}
