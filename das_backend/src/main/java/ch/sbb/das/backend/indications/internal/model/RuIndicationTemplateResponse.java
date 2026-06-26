package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record RuIndicationTemplateResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<RuIndicationTemplate> data)
    implements ApiResponse<RuIndicationTemplate> {

    public RuIndicationTemplateResponse(RuIndicationTemplate ruIndicationTemplate) {
        this(List.of(ruIndicationTemplate));
    }

}

