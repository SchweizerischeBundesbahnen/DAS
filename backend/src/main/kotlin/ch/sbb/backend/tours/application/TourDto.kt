package ch.sbb.backend.tours.application

import io.swagger.v3.oas.annotations.media.Schema


@Schema(name = "Tour")
data class TourDto(
    @Schema(
        description = "Identification of the user (e.g. email address)",
        example = "michael.mueller@sbb.ch"
    )
    val userId: String,

    @Schema(
        description = "Identification of the tour. Unique per company",
        example = "123456"
    )
    val tourId: String,

    @Schema(
        description = "Company code",
        example = "1085"
    )
    val company: String,

    val trainRuns: List<TrainRunDto>,

    )
