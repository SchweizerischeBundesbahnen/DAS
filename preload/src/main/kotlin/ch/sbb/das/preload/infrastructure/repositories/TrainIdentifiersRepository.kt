package ch.sbb.das.preload.infrastructure.repositories

import ch.sbb.das.preload.infrastructure.entities.TrainIdentifierEntity
import ch.sbb.das.preload.infrastructure.entities.TrainIdentifierId
import org.springframework.data.repository.ListCrudRepository
import org.springframework.stereotype.Repository

@Repository
interface TrainIdentifiersRepository : ListCrudRepository<TrainIdentifierEntity, TrainIdentifierId> {
}
