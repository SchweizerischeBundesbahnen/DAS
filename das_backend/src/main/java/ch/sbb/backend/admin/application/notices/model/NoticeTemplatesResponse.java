package ch.sbb.backend.admin.application.notices.model;

import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record NoticeTemplatesResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<NoticeTemplate> data)
    implements ApiResponse<NoticeTemplate> {

}
