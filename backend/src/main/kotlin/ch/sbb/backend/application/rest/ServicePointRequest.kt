package ch.sbb.backend.application.rest

import io.swagger.v3.oas.annotations.media.Schema

@Schema(name = "ServicePoint")
data class ServicePointRequest(

    @Schema(
        description = "UIC-Code, combination of uicCountryCode and numberShort. Size: 7",
        example = "8518771"
    )
    val uic: Int,

    @Schema(
        description = "Official designation of a location",
        example = "Biel/Bienne Bözingenfeld/Champ"
    )
    val designation: String,

    @Schema(
        description = "Location abbreviation",
        example = "BIBD"
    )
    val abbreviation: String,
)
