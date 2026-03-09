package ch.sbb.backend.admin.application.settings.model.request;

import java.time.LocalDate;

public record AppVersionUpdateRequest(
    String version,
    Boolean minimalVersion,
    LocalDate expiryDate,
    String lastModifiedBy
) {

}
