package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;

class EuropeanVehicleNumberTest {

    @Test
    void asString_null() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber(null, null);
        assertNull(europeanVehicleNumber.asString());
    }

    @Test
    void asString_correct() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("67", "462892");
        assertEquals("67462892", europeanVehicleNumber.asString());
    }

    @Test
    void asString_invalid() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber(null, "462892");
        assertNull(europeanVehicleNumber.asString());
    }
}