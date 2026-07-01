package ch.sbb.das.backend.indications.internal.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Status of a RU indication.")
public enum PeriodStatus {
    INACTIVE,
    ACTIVE,
    EXPIRED
}
