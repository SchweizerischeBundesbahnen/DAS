package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class EuropeanVehicleNumber {

    private String typeCode;
    private String countryCodeUic;
    private String vehicleNumber;
    private String checkDigit;

    public String toVehicleCode() {
        if (typeCode == null || countryCodeUic == null || vehicleNumber == null || checkDigit == null) {
            return null;
        }
        return typeCode + countryCodeUic + vehicleNumber + checkDigit;
    }
}
