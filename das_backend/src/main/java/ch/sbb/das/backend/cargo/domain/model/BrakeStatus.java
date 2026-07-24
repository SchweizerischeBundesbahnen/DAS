package ch.sbb.das.backend.cargo.domain.model;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
@Slf4j
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
