package ch.sbb.backend.preload.infrastructure.repositories

import ch.sbb.backend.preload.infrastructure.entities.TrainIdentificationEntity
import ch.sbb.backend.preload.infrastructure.entities.TrainIdentificationId
import org.springframework.data.repository.ListCrudRepository
import org.springframework.stereotype.Repository

@Repository
interface SpringDataJpaTrainIdentificationRepository :
    ListCrudRepository<TrainIdentificationEntity, TrainIdentificationId> {}
