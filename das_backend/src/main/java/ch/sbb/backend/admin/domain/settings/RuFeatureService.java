package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import java.util.List;

public interface RuFeatureService {

    List<RuFeature> getAll();
}
