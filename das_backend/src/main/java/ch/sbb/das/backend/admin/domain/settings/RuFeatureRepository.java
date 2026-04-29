package ch.sbb.das.backend.admin.domain.settings;

import ch.sbb.das.backend.admin.domain.settings.model.RuFeature;
import java.util.List;

public interface RuFeatureRepository {

    List<RuFeature> findAll();
}
