package ch.sbb.backend.preload.infrastructure.repositories

import ch.sbb.backend.BaseTestcontainersTest
import ch.sbb.backend.preload.domain.TrainIdentification
import ch.sbb.backend.preload.domain.repository.TrainIdentificationRepository
import ch.sbb.backend.preload.infrastructure.entities.TrainIdentificationEntity
import ch.sbb.backend.preload.infrastructure.entities.TrainIdentificationId
import org.assertj.core.api.Assertions.assertThat
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import java.time.LocalDate
import java.time.OffsetDateTime
import kotlin.test.Test

@DataJpaTest
class TrainIdentificationEntityIntegrationTest : BaseTestcontainersTest() {

    @Autowired
    lateinit var trainIdentificationRepository: SpringDataJpaTrainIdentificationRepository

    @Autowired
    lateinit var em: TestEntityManager

    @Test
    fun givenNewTrainIdentifier_whenSave_thenSuccess() {
        val identifier = "1111"
        val operationDate = LocalDate.now()
        val ru = "22"
        val startTime = OffsetDateTime.now()

        val train = TrainIdentificationEntity(identifier, operationDate, ru, startTime)
        trainIdentificationRepository.save(train)

        val result = em.find(
            TrainIdentificationEntity::class.java,
            TrainIdentificationId(identifier, operationDate, ru)
        )
        assertThat(result.startDateTime).isEqualTo(startTime)
    }

    @Test
    fun givenTrainIdentifierCreated_whenUpdate_thenSuccess() {
        val identifier = "1111"
        val operationDate = LocalDate.now()
        val ru = "22"
        val startTime = OffsetDateTime.now()

        val train = TrainIdentificationEntity(identifier, operationDate, ru, startTime)
        em.persist(train)

        val newStartTime = OffsetDateTime.now()
        train.startDateTime = newStartTime
        em.persist(train)

        val result = em.find(
            TrainIdentificationEntity::class.java,
            TrainIdentificationId(identifier, operationDate, ru)
        )
        assertThat(result.startDateTime).isEqualTo(newStartTime)
    }
}
