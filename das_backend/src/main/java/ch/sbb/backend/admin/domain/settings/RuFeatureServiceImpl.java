package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import java.util.List;

public class RuFeatureServiceImpl implements RuFeatureService {

    private final RuFeatureRepository ruFeatureRepository;

    public RuFeatureServiceImpl(RuFeatureRepository ruFeatureRepository) {
        this.ruFeatureRepository = ruFeatureRepository;
    }

    @Override
    public List<RuFeature> getAll() {
        return ruFeatureRepository.findAll();
    }

}
