package ch.sbb.das.backend.admin.application.notices.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record NoticeMatchesResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<NoticeMatch> data
) implements ApiResponse<NoticeMatch> {

}
