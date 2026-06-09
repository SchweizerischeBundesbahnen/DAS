package ch.sbb.das.backend.admin.application.links.model;

import ch.sbb.das.backend.admin.application.common.TranslatedContentRequest;
import ch.sbb.das.backend.admin.application.common.ValidTranslatedContent;
import ch.sbb.das.backend.common.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import org.apache.commons.lang3.StringUtils;

import java.util.Set;

@Schema(description = "The external link payload. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record ExternalLinkRequest(
        @Schema(description = "The RICS company codes on which this external link is showed.", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotEmpty
        Set<CompanyCode> companies,
        @Schema(description = "The german external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        @Valid
        ExternalLinkContent de,
        @Schema(description = "The french external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        @Valid
        ExternalLinkContent fr,
        @Schema(description = "The italian external link content.", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        @Valid
        ExternalLinkContent it) implements TranslatedContentRequest<ExternalLinkContent> {
    public ExternalLinkRequest {
        de = normalize(de);
        fr = normalize(fr);
        it = normalize(it);
    }

    @Override
    public ExternalLinkContent normalize(ExternalLinkContent content) {
        if (content == null || (StringUtils.isBlank(content.title()) && StringUtils.isBlank(content.link()))) {
            return null;
        }
        return content;
    }
}
