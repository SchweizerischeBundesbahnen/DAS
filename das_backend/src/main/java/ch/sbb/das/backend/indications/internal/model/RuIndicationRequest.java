package ch.sbb.das.backend.indications.internal.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record RuIndicationRequest(
    @Schema(description = "Content of a RU indication.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull @Valid RuIndicationContent content,
    @Schema(description = "Scope for a RU indication.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull @Valid RuIndicationScope scope,
    @Schema(description = "RU indication validity periods.", requiredMode = Schema.RequiredMode.REQUIRED)
    List<@Valid RuIndicationPeriod> periods
) {

}

