package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.infrastructure.settings.model.RuFeatureEntity;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaRuFeatureRepository extends ListCrudRepository<RuFeatureEntity, Integer> {

}
