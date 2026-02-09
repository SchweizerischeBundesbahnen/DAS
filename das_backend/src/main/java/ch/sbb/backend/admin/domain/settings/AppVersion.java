package ch.sbb.backend.admin.domain.settings;

import java.time.LocalDate;

public record AppVersion(
    Long id,
    String version,
    Boolean minimalVersion,
    LocalDate expiryDate
) {

}
