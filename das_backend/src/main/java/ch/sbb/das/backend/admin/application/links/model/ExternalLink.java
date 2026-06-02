package ch.sbb.das.backend.admin.application.links.model;

import ch.sbb.das.backend.common.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.Set;

@Schema(description = "The external link payload. At least one language object (de, fr, or it) must be provided.")
public record ExternalLink(
        @Schema(description = "The unique identifier for the external link entry.", requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
        Integer id,
        @Schema(description = "The RICS company codes on which this external link is showed.", requiredMode = Schema.RequiredMode.REQUIRED)
        Set<CompanyCode> companies,
        @Schema(description = "The german external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        ExternalLinkContent de,
        @Schema(description = "The french external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        ExternalLinkContent fr,
        @Schema(description = "The italian external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        ExternalLinkContent it,
        @Schema(description = "The timestamp of the last edit to the external link.", requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
        LocalDateTime lastModifiedAt,
        @Schema(description = "The user who last edited the external link.", requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
        String lastModifiedBy
) {
}
