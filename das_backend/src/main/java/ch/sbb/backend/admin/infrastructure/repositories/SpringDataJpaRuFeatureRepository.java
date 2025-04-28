package ch.sbb.backend.admin.infrastructure.repositories;

import ch.sbb.backend.admin.infrastructure.model.RuFeatureEntity;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaRuFeatureRepository extends ListCrudRepository<RuFeatureEntity, Integer> {

}
