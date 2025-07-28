package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EuropeanVehicleNumberTest {

    @Test
    void toVehicleCode_null() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber(null, null, null, null);
        assertThat(europeanVehicleNumber.toVehicleCode()).isNull();
    }

    @Test
    void toVehicleCode_correct() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("74", "67", "462892", "5");
        assertThat(europeanVehicleNumber.toVehicleCode()).isEqualTo("74674628925");
    }

    @Test
    void toVehicleCode_invalid() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("45", null, "462892", "3");
        assertThat(europeanVehicleNumber.toVehicleCode()).isNull();
    }
}