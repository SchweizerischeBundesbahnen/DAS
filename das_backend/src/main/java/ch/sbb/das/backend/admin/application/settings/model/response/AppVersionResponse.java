package ch.sbb.das.backend.admin.application.settings.model.response;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record AppVersionResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<AppVersion> data)
    implements ApiResponse<AppVersion> {

    public AppVersionResponse(AppVersion appVersion) {
        this(List.of(appVersion));
    }

}

