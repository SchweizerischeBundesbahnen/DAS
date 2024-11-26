package ch.sbb.backend.infrastructure.repositories

import ch.sbb.backend.infrastructure.entities.ServicePointEntity
import org.springframework.data.repository.ListCrudRepository
import org.springframework.stereotype.Repository

@Repository
interface ServicePointsRepository : ListCrudRepository<ServicePointEntity, Int> {
     fun findByUic(uic: Int): ServicePointEntity?
}
