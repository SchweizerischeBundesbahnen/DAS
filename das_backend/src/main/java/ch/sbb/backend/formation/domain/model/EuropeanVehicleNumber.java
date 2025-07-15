package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class EuropeanVehicleNumber {

    private String countryCodeUic;
    private String vehicleNumber;

    @Override
    public String toString() {
        return countryCodeUic + vehicleNumber;
    }
}
