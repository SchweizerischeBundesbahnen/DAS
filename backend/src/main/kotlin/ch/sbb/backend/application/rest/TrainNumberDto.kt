package ch.sbb.backend.application.rest

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema(name = "Train number")
data class TrainNumberDto(

    @Schema(
        description = "Train number alphanumeric",
        example = "123"
    )
    val number: String,

    @Schema(
        description = "Identifies a railway undertaking code (UIC RICS Code: https://uic.org/rics)",
        example = "1085"
    )
    val ru: String,

    @Schema(
        type = "number",
        format = "double",
        description = "Timestamp of the start of train operation in seconds since epoch or timestamp",
        example = "1727188352.001"
    )
    val start: OffsetDateTime,
)
