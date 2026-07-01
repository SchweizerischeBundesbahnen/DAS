package ch.sbb.das.backend.indications.internal.model;

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

    public static RuIndicationEntry normalize(RuIndicationEntry entry) {
        if (entry == null || (StringUtils.isBlank(entry.title()) && StringUtils.isBlank(entry.text()))) {
            return null;
        }
        return entry;
    }
}
