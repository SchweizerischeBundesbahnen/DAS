package ch.sbb.backend.admin.application.settings.model.response;

import ch.sbb.backend.admin.domain.settings.model.AppVersion;
import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record AppVersionResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED)) List<AppVersion> data)
    implements ApiResponse<AppVersion> {

}

