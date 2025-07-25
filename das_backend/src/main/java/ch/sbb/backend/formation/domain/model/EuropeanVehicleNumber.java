package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class EuropeanVehicleNumber {

    private String countryCodeUic;
    private String vehicleNumber;

    public String toVehicleCode() {
        if (countryCodeUic == null || vehicleNumber == null) {
            return null;
        }
        return countryCodeUic + vehicleNumber;
    }
}
