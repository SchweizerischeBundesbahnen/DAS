package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDateTime;
import java.util.List;

public record Notice(
    @Schema(description = "The unique identifier of the notice.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "Title and text content of the notice.", requiredMode = RequiredMode.REQUIRED)
    NoticeContent content,
    @Schema(description = "Scope of the notice.", requiredMode = RequiredMode.REQUIRED)
    NoticeScope scope,
    @Schema(description = "Valid periods of the notice.", requiredMode = RequiredMode.REQUIRED)
    List<NoticePeriod> periods,
    @Schema(description = "The timestamp of the last update to the notice entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who created or last updated the notice.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public Notice(Integer id, NoticeContent content, NoticeScope scope, List<NoticePeriod> periods) {
        this(id, content, scope, periods, null, null);
    }
}

