package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import org.jetbrains.annotations.NotNull;

@AllArgsConstructor
public class TafTapLocationReference {

    private Integer countryCodeUic;
    private Integer uicCode;
    
    @NotNull
    @Override
    public String toString() {
        return String.format("%02d", countryCodeUic) + String.format("%06d", uicCode);
    }

}
