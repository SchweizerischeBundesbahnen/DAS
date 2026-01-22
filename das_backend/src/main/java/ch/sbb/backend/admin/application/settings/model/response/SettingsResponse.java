package ch.sbb.backend.admin.application.settings.model.response;

import ch.sbb.backend.common.model.response.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record SettingsResponse(
        @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 1, maxItems = 1)
        List<Settings> data
) implements ApiResponse<Settings> {
}
