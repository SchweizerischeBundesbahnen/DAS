package ch.sbb.backend.admin.domain.repository;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.admin.domain.model.ServicePoint;
import ch.sbb.backend.admin.domain.service.DomainServicePointService;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class DomainServicePointServiceTest {

    private ServicePointRepository servicePointRepository;
    private DomainServicePointService underTest;

    @BeforeEach
    void setUp() {
        servicePointRepository = mock(ServicePointRepository.class);
        underTest = new DomainServicePointService(servicePointRepository);
    }

    @Test
    void shouldUpdateServicePoints_thenSave() {
        var servicePoints = List.of(new ServicePoint(1, "designation", "abbreviation"));
        underTest.updateAll(servicePoints);
        verify(servicePointRepository).saveAll(servicePoints);
    }
}
