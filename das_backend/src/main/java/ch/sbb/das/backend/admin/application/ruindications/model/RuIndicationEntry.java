package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import org.apache.commons.lang3.StringUtils;

public record RuIndicationEntry(
    @Schema(description = "The title of the RU indication template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank
    String title,
    @Schema(description = "The text of the RU indication template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    String text
) {

    public static RuIndicationEntry normalizeIfEmpty(RuIndicationEntry entry) {
        if (entry == null) {
            return null;
        }
        if (StringUtils.isBlank(entry.title()) && StringUtils.isBlank(entry.text())) {
            return null;
        }
        return entry;
    }
}
