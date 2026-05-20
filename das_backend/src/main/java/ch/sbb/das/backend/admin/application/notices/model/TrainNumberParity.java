package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Train number range parity.")
public enum TrainNumberParity {
    ANY,
    EVEN,
    ODD
}
