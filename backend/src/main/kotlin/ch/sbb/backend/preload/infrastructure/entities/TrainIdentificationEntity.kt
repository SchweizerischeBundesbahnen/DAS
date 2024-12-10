package ch.sbb.backend.preload.infrastructure.entities

import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.IdClass
import java.time.LocalDate
import java.time.OffsetDateTime

@Entity(name = "train_identification")
@IdClass(TrainIdentificationId::class)
class TrainIdentificationEntity(
    @Id
    var operationalTrainNumber: String,
    @Id
    var startDate: LocalDate,
    @Id
    var company: String,
    var startDateTime: OffsetDateTime
)
