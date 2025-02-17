package ch.sbb.backend.tours.application

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate

@Schema(name = "Train Identification")
class TrainIdentificationDto(
    @Schema(
        description = "Identifies the train",
        example = "123456"
    )
    var operationalTrainNumber: String,

    @Schema(
        description = "Start date",
        example = "2024-12-24"
    )
    var startDate: LocalDate,

    @Schema(
        description = "Company code of the railway undertaking",
        example = "1085"
    )
    var company: String,

    )
