package ch.sbb.backend.preload.infrastructure.repositories

import ch.sbb.backend.preload.domain.TrainIdentification
import ch.sbb.backend.preload.domain.repository.TrainIdentificationRepository
import ch.sbb.backend.preload.infrastructure.entities.TrainIdentificationEntity
import org.springframework.stereotype.Component

@Component
class PostgreSQLTrainIdentificationRepository(private val trainIdentificationRepository: SpringDataJpaTrainIdentificationRepository) :
    TrainIdentificationRepository {
    override fun save(trainIdentification: TrainIdentification) {
        trainIdentificationRepository.save(TrainIdentificationEntity(trainIdentification))
    }
}
