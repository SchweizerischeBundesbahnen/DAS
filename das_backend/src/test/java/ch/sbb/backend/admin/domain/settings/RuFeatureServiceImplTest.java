package ch.sbb.backend.admin.domain.settings;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.backend.admin.domain.settings.model.Company;
import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import ch.sbb.backend.admin.domain.settings.model.RuFeatureKey;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class RuFeatureServiceImplTest {

    private RuFeatureRepository ruFeatureRepository;
    private RuFeatureServiceImpl underTest;

    @BeforeEach
    void setUp() {
        ruFeatureRepository = mock(RuFeatureRepository.class);
        underTest = new RuFeatureServiceImpl(ruFeatureRepository);
    }

    @Test
    void shouldGetAllRuFeatures() {
        List<RuFeature> expectedRuFeatures = List.of(new RuFeature(new Company("4444", "COMP4"), RuFeatureKey.CUSTOMER_ORIENTED_DEPARTURE_PROCESS, true));
        when(ruFeatureRepository.findAll()).thenReturn(expectedRuFeatures);

        List<RuFeature> actualRuFeatures = underTest.getAll();
        assertThat(actualRuFeatures).isEqualTo(expectedRuFeatures);
    }
}
