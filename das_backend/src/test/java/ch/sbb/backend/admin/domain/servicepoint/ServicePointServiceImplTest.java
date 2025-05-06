package ch.sbb.backend.admin.domain.servicepoint;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.admin.domain.servicepoint.model.ServicePoint;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class ServicePointServiceImplTest {

    private ServicePointRepository servicePointRepository;
    private ServicePointServiceImpl underTest;

    @BeforeEach
    void setUp() {
        servicePointRepository = mock(ServicePointRepository.class);
        underTest = new ServicePointServiceImpl(servicePointRepository);
    }

    @Test
    void shouldUpdateServicePoints_thenSave() {
        var servicePoints = List.of(new ServicePoint(1, "designation", "abbreviation"));
        underTest.updateAll(servicePoints);
        verify(servicePointRepository).saveAll(servicePoints);
    }
}
