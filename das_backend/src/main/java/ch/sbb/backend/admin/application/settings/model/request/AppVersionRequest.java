package ch.sbb.backend.admin.application.settings.model.request;

import static ch.sbb.backend.admin.domain.settings.model.SemanticVersion.SEM_VERSION_PATTERN;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;

public record AppVersionRequest(
    @Pattern(regexp = SEM_VERSION_PATTERN) String version,
    @NotNull Boolean minimalVersion,
    LocalDate expiryDate
) {

}
