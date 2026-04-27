package ch.sbb.backend.admin.application.notices.model;

import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record NoticeTemplateResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<NoticeTemplate> data)
    implements ApiResponse<NoticeTemplate> {

    public NoticeTemplateResponse(NoticeTemplate noticeTemplate) {
        this(List.of(noticeTemplate));
    }

}

