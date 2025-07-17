package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class TafTapLocationReference {

    private Integer countryCodeUic;
    private Integer uicCode;

    @Override
    public String toString() {
        if (countryCodeUic == null || uicCode == null) {
            return "";
        }
        return String.format("%02d", countryCodeUic) + String.format("%06d", uicCode);
    }

}
