package ch.sbb.das.backend.locations.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import java.time.LocalDate;
import org.springframework.stereotype.Component;

@Component
public class TafTapLocationMapper {

    private static TafTapLocationReference toLocationReference(ServicePoint.ServicePointNumber servicePointNumber) {
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(servicePointNumber.uicCountryCode());
        return new TafTapLocationReference(countryCodeIso, servicePointNumber.numberShort());
    }

    public TafTapLocationEntity toEntityFromServicePoint(ServicePoint sp) {
        return new TafTapLocationEntity(null, toLocationReference(sp.number()).toLocationCode(), sp.designationOfficial(), sp.abbreviation(), sp.validFrom(), sp.validTo());
    }

    public TafTapLocation toResponse(TafTapLocationEntity entity) {
        LocalDate validFrom = entity.getValidFrom();
        LocalDate validFromInFuture = validFrom != null && validFrom.isAfter(DateTimeUtil.today()) ? validFrom : null;
        return new TafTapLocation(
            entity.getLocationReference(),
            entity.getPrimaryLocationName(),
            entity.getLocationAbbreviation(),
            validFromInFuture
        );
    }
}
