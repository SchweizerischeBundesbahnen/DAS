package ch.sbb.backend.admin.application.settings.model.response;

import ch.sbb.backend.admin.application.settings.AppVersionEntity;
import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record AppVersionResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED)) List<AppVersionEntity> data)
    implements ApiResponse<AppVersionEntity> {

}

