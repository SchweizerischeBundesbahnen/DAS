package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record RuIndicationTemplatesResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<RuIndicationTemplate> data)
    implements ApiResponse<RuIndicationTemplate> {

}
