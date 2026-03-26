package ch.sbb.backend.admin.infrastructure.locations;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaLocationRepository extends ListCrudRepository<LocationEntity, Integer> {

}
