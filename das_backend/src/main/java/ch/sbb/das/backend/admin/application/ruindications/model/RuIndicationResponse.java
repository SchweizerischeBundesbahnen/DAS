package ch.sbb.das.backend.admin.application.ruindications.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record RuIndicationResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1)
    List<RuIndication> data
) implements ApiResponse<RuIndication> {

    public RuIndicationResponse(RuIndication ruIndication) {
        this(List.of(ruIndication));
    }
}

