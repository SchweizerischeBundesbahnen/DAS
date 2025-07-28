package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class BrakeStatusTest {

    @Test
    void isDabled_null() {
        BrakeStatus brakeStatus = new BrakeStatus(null);
        assertFalse(brakeStatus.isDisabled());
    }

    @Test
    void isDabled_true() {
        BrakeStatus brakeStatus = new BrakeStatus(0);
        assertTrue(brakeStatus.isDisabled());
    }

    @Test
    void isDabled_false() {
        BrakeStatus brakeStatus = new BrakeStatus(3);
        assertFalse(brakeStatus.isDisabled());
    }
}