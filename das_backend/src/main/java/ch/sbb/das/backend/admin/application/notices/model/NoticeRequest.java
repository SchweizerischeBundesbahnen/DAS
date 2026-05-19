package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record NoticeRequest(
    @Schema(description = "Content of a notice.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull @Valid NoticeContent content,
    @Schema(description = "Scope for a notice.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull @Valid NoticeScope scope,
    @Schema(description = "Notice validity periods.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@Valid NoticePeriod> periods
) {

}

