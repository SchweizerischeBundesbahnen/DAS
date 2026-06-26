package ch.sbb.das.backend.feature.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.feature.RuFeature;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class RuFeatureServiceImplTest {

    private RuFeatureRepository ruFeatureRepository;
    private RuFeatureMapper ruFeatureMapper;
    private RuFeatureServiceImpl underTest;

    @BeforeEach
    void setUp() {
        ruFeatureRepository = mock(RuFeatureRepository.class);
        ruFeatureMapper = mock(RuFeatureMapper.class);
        underTest = new RuFeatureServiceImpl(ruFeatureRepository, ruFeatureMapper);
    }

    @Test
    void shouldGetAllRuFeatures() {
        CompanyEntity companyEntity = new CompanyEntity();
        companyEntity.setCodeRics("4444");

        RuFeatureEntity ruFeatureEntity = new RuFeatureEntity();
        ruFeatureEntity.setCompany(companyEntity);
        ruFeatureEntity.setKeyValue("CUSTOMER_ORIENTED_DEPARTURE_PROCESS");
        ruFeatureEntity.setEnabled(true);

        RuFeature expectedRuFeature = new RuFeature(new CompanyCode("4444"), "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", true);
        List<RuFeature> expectedRuFeatures = List.of(expectedRuFeature);

        when(ruFeatureRepository.findAll()).thenReturn(List.of(ruFeatureEntity));
        when(ruFeatureMapper.toResponse(ruFeatureEntity)).thenReturn(expectedRuFeature);

        List<RuFeature> actualRuFeatures = underTest.getAll();
        assertThat(actualRuFeatures).isEqualTo(expectedRuFeatures);
    }
}
