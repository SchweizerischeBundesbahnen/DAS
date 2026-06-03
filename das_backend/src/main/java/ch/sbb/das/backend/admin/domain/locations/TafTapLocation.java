package ch.sbb.das.backend.admin.domain.locations;

import ch.sbb.das.backend.common.DateUtil;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.time.LocalDate;

public record TafTapLocation(TafTapLocationReference locationReference, String primaryLocationName, String locationAbbreviation, LocalDate validFrom, LocalDate validTo) {

    private static final int YEARS_IN_FUTURE = 1;

    public boolean valid() {
        return validFrom.isBefore(DateUtil.today().plusYears(YEARS_IN_FUTURE));
    }

    public LocalDate futureValidFrom() {
        if (validFrom().isAfter(DateUtil.today())) {
            return validFrom;
        }
        return null;
    }
}
