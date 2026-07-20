package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.features.RuFeature;
import org.springframework.stereotype.Component;

@Component
public class RuFeatureMapper {

    public RuFeature toRuFeature(RuFeatureEntity entity) {
        return new RuFeature(entity.getCompanyCode(), entity.getCompanyCode(), entity.getKeyValue(), entity.isEnabled());
    }

    InternalRuFeature toInternalRuFeature(RuFeatureEntity entity) {
        return new InternalRuFeature(entity.getId(), entity.getCompanyCode(), entity.getKeyValue(), entity.isEnabled(),
            entity.getLastModifiedAt(), entity.getLastModifiedBy());
    }

    RuFeatureEntity toEntity(RuFeatureRequest request) {
        RuFeatureEntity entity = new RuFeatureEntity();
        updateEntity(entity, request);
        return entity;
    }

    void updateEntity(RuFeatureEntity entity, RuFeatureRequest request) {
        entity.setCompanyCode(request.companyCode());
        entity.setKeyValue(request.key().name());
        entity.setEnabled(request.enabled());
    }
}
