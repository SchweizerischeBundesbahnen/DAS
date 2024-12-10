package ch.sbb.backend.tours.application

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema(name = "Train run")
class TrainRunDto(
    @Schema(
        description = "Train identification",
    )
    val trainIdentification: TrainIdentificationDto,

    @Schema(
        description = "UIC-Code of the start location, combination of uicCountryCode and numberShort. Size: 7",
        example = "8518771"
    )
    val startUic: String,

    @Schema(
        description = "UIC-Code of the end location, combination of uicCountryCode and numberShort. Size: 7",
        example = "8518771"
    )
    val endUic: String,

    @Schema(
        description = "Start date time",
        example = "2024-12-24T12:00:00Z"
    )
    var startDateTime: OffsetDateTime,

    @Schema(
        description = "End date time",
        example = "2024-12-24T12:00:00Z"
    )
    var endDateTime: OffsetDateTime,
)
