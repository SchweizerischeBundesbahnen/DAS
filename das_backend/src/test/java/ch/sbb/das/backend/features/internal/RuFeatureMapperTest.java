package ch.sbb.das.backend.features.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.features.RuFeature;
import org.junit.jupiter.api.Test;

class RuFeatureMapperTest {

    private final RuFeatureMapper mapper = new RuFeatureMapper();

    @Test
    void toResponse_maps_entity_to_ruFeature() {
        RuFeatureEntity entity = new RuFeatureEntity();
        entity.setId(10);
        entity.setCompanyCode(new CompanyCode("2185"));
        entity.setKeyValue("WARNAPP");
        entity.setEnabled(true);

        RuFeature result = mapper.toResponse(entity);

        assertThat(result.id()).isEqualTo(10);
        assertThat(result.companyCode()).isEqualTo(new CompanyCode("2185"));
        assertThat(result.key()).isEqualTo("WARNAPP");
        assertThat(result.enabled()).isTrue();
    }

    @Test
    void toEntity_creates_entity_from_request() {
        RuFeatureRequest request = new RuFeatureRequest(new CompanyCode("2185"), RuFeatureKey.WARNAPP, true);

        RuFeatureEntity result = mapper.toEntity(request);

        assertThat(result.getCompanyCode()).isEqualTo(new CompanyCode("2185"));
        assertThat(result.getKeyValue()).isEqualTo("WARNAPP");
        assertThat(result.isEnabled()).isTrue();
        assertThat(result.getId()).isNull();
    }

    @Test
    void updateEntity_updates_existing_entity_fields() {
        RuFeatureEntity entity = new RuFeatureEntity();
        entity.setId(10);
        entity.setCompanyCode(new CompanyCode("2185"));
        entity.setKeyValue("WARNAPP");
        entity.setEnabled(false);

        RuFeatureRequest request = new RuFeatureRequest(new CompanyCode("1185"), RuFeatureKey.CHECKLIST_DEPARTURE_PROCESS, true);

        mapper.updateEntity(entity, request);

        assertThat(entity.getId()).isEqualTo(10);
        assertThat(entity.getCompanyCode()).isEqualTo(new CompanyCode("1185"));
        assertThat(entity.getKeyValue()).isEqualTo("CHECKLIST_DEPARTURE_PROCESS");
        assertThat(entity.isEnabled()).isTrue();
    }
}
