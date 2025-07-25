package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@EqualsAndHashCode
@Slf4j
public class TafTapLocationReference {

    private Integer countryCodeUic;
    private Integer uicCode;

    /**
     * @return proprietary short, speaking format within this project. Related to SLOID.
     */
    public String toLocationCode() {
        if (countryCodeUic == null || uicCode == null) {
            log.warn("TafTapLocationReference: countryCodeUic or uicCode is null, cannot create location code.");
            return null;
        }
        return String.format("%02d", countryCodeUic) + String.format("%06d", uicCode);
    }

}
