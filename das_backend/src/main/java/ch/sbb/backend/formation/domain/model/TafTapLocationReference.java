package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;

@AllArgsConstructor
@EqualsAndHashCode
public class TafTapLocationReference {

    private Integer countryCodeUic;
    private Integer uicCode;

    public String asString() {
        if (countryCodeUic == null || uicCode == null) {
            return null;
        }
        return String.format("%02d", countryCodeUic) + String.format("%06d", uicCode);
    }

}
