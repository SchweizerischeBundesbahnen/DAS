package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class BrakeStatus {

    private static final int DISABLED_BRAKE_STATUS = 0;
    private Integer brakeStatus;

    boolean isDisabled() {
        return brakeStatus == DISABLED_BRAKE_STATUS;
    }
}
