package ch.sbb.backend.servicepoints.domain.repository

import ch.sbb.backend.servicepoints.domain.ServicePoint
import ch.sbb.backend.servicepoints.domain.service.DomainServicePointService
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify


class DomainServicePointServiceTest {

    private lateinit var servicePointRepository: ServicePointRepository
    private lateinit var tested: DomainServicePointService

    @BeforeEach
    fun setUp() {
        servicePointRepository = mock(ServicePointRepository::class.java)
        tested = DomainServicePointService(servicePointRepository)
    }

    @Test
    fun shouldUpdateServicePoints_thenSave() {
        val servicePoints: List<ServicePoint> =
            listOf(ServicePoint(1, "designation", "abbreviation"))
        tested.updateAll(servicePoints)
        verify(servicePointRepository).saveAll(servicePoints)

    }
}
