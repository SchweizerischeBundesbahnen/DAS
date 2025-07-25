package ch.sbb.backend.formation.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class BrakeStatus {

    private static final int DISABLED_BRAKE_STATUS = 0;
    private Integer brakeStatus;

    boolean isDisabled() {
        if (brakeStatus == null) {
            return false;
        }
        return brakeStatus == DISABLED_BRAKE_STATUS;
    }
}
