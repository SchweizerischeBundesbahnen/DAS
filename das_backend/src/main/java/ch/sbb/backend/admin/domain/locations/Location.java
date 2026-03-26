package ch.sbb.backend.admin.domain.locations;

import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import java.time.LocalDate;

public record Location(TafTapLocationReference locationReference, String primaryLocationName, String locationAbbreviation, LocalDate validFrom, LocalDate validTo) {

    private static final int YEARS_IN_FUTURE = 1;

    public boolean isFuture() {
        return validFrom().isAfter(LocalDate.now());
    }

    public boolean valid() {
        return validFrom.isBefore(LocalDate.now().plusYears(YEARS_IN_FUTURE));
    }
}
