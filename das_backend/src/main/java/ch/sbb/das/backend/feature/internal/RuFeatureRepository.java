package ch.sbb.das.backend.feature.internal;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RuFeatureRepository extends ListCrudRepository<RuFeatureEntity, Integer> {

}
