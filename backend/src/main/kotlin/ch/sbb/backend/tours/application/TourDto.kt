package ch.sbb.backend.tours.application

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate


@Schema(name = "Tour")
data class TourDto(
    @Schema(
        description = "Identification of the user (e.g. email address)",
        example = "michael.mueller@sbb.ch"
    )
    val userId: String,

    @Schema(
        description = "Identification of the tour. Unique for day and company",
        example = "123456"
    )
    val tourId: String,

    @Schema(
        description = "Start date of the tour",
        example = "2024-12-24"
    )
    val startDate: LocalDate,


    @Schema(
        description = "Company code",
        example = "1085"
    )
    val company: String,

    val trainRuns: List<TrainRunDto>,

    )
