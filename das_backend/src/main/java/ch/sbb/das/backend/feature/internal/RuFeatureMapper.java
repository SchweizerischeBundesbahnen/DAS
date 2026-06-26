package ch.sbb.das.backend.feature.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.feature.RuFeature;
import org.springframework.stereotype.Component;

@Component
public class RuFeatureMapper {

    public RuFeature toResponse(RuFeatureEntity entity) {
        return new RuFeature(new CompanyCode(entity.getCompany().getCodeRics()), entity.getKeyValue(), entity.isEnabled());
    }
}
