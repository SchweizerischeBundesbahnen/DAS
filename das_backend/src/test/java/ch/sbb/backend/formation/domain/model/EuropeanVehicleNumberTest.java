package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EuropeanVehicleNumberTest {

    @Test
    void toVehicleCode_null() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber(null, null);
        assertThat(europeanVehicleNumber.toVehicleCode()).isNull();
    }

    @Test
    void toVehicleCode_correct() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("67", "462892");
        assertThat(europeanVehicleNumber.toVehicleCode()).isEqualTo("67462892");
    }

    @Test
    void toVehicleCode_invalid() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber(null, "462892");
        assertThat(europeanVehicleNumber.toVehicleCode()).isNull();
    }
}