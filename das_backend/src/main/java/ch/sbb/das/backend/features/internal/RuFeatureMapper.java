package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.features.RuFeature;
import org.springframework.stereotype.Component;

@Component
public class RuFeatureMapper {

    public RuFeature toResponse(RuFeatureEntity entity) {
        return new RuFeature(entity.getCompanyCode(), entity.getKeyValue(), entity.isEnabled());
    }
}
