package ch.sbb.das.preload.infrastructure.entities

import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.IdClass
import java.time.LocalDate
import java.time.OffsetDateTime

@Entity(name = "train_identifier")
@IdClass(TrainIdentifierId::class)
class TrainIdentifierEntity(
    @Id
    var identifier: String,
    @Id
    var operationDate: LocalDate,
    @Id
    var ru: String,
    var startDateTime: OffsetDateTime
)
