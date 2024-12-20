package ch.sbb.backend.preload.domain

import java.time.LocalDate
import java.time.OffsetDateTime

data class TrainIdentification(
    val operationalTrainNumber: String,
    val startDate: LocalDate,
    val company: String,
    val startDateTime: OffsetDateTime
)
