package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.domain.settings.RuFeatureRepository;
import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import ch.sbb.backend.admin.infrastructure.settings.model.RuFeatureEntity;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
class PersistenceRuFeatureRepository implements RuFeatureRepository {

    private final SpringDataJpaRuFeatureRepository ruFeatureRepository;

    PersistenceRuFeatureRepository(SpringDataJpaRuFeatureRepository ruFeatureRepository) {
        this.ruFeatureRepository = ruFeatureRepository;
    }

    @Override
    public List<RuFeature> findAll() {
        return ruFeatureRepository.findAll().stream().map(RuFeatureEntity::toRuFeature).toList();
    }
}
