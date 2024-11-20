package ch.sbb.backend.application.rest

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate
import java.time.OffsetDateTime

@Schema(name = "Train identifier")
data class TrainIdentifierDto(

    @Schema(description = "Train identifier", example = "819")
    val identifier: String,

    @Schema(description = "Operation date of the train", type = "string", format = "date")
    val operationDate: LocalDate,

    @Schema(description = "Timestamp of the start of train operation")
    val startDateTime: OffsetDateTime,
)
