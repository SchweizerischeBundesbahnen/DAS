package ch.sbb.backend.servicepoints.infrastructure.repositories

import ch.sbb.backend.servicepoints.infrastructure.entities.ServicePointEntity
import org.springframework.data.repository.ListCrudRepository
import org.springframework.stereotype.Repository

@Repository
interface SpringDataJpaServicePointRepository : ListCrudRepository<ServicePointEntity, Int> {
     fun findByUic(uic: Int): ServicePointEntity?
}
