package ch.sbb.das.preload

import ch.sbb.das.preload.infrastructure.entities.TrainIdentifierEntity
import ch.sbb.das.preload.infrastructure.entities.TrainIdentifierId
import ch.sbb.das.preload.infrastructure.repositories.TrainIdentifiersRepository
import org.assertj.core.api.Assertions.assertThat
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import org.testcontainers.utility.DockerImageName
import java.time.LocalDate
import java.time.OffsetDateTime
import kotlin.test.Test

@DataJpaTest
@Testcontainers
class TrainIdentifierEntityIntegrationTest {

    companion object {
        @Container
        @ServiceConnection
        @JvmStatic
        val postgres = PostgreSQLContainer(DockerImageName.parse("postgres:latest"))
    }

    @Autowired
    lateinit var trainIdentifiersRepository: TrainIdentifiersRepository

    @Autowired
    lateinit var em: TestEntityManager

    @Test
    fun givenNewTrainIdentifier_whenSave_thenSuccess() {
        val identifier = "1111"
        val operationDate = LocalDate.now()
        val ru = "22"
        val startTime = OffsetDateTime.now()

        val train = TrainIdentifierEntity(identifier, operationDate, ru, startTime)
        trainIdentifiersRepository.save(train)

        val result = em.find(
            TrainIdentifierEntity::class.java,
            TrainIdentifierId(identifier, operationDate, ru)
        )
        assertThat(result.startDateTime).isEqualTo(startTime)
    }

    @Test
    fun givenTrainIdentifierCreated_whenUpdate_thenSuccess() {
        val identifier = "1111"
        val operationDate = LocalDate.now()
        val ru = "22"
        val startTime = OffsetDateTime.now()

        val train = TrainIdentifierEntity(identifier, operationDate, ru, startTime)
        em.persist(train)

        val newStartTime = OffsetDateTime.now()
        train.startDateTime = newStartTime
        em.persist(train)

        val result = em.find(
            TrainIdentifierEntity::class.java,
            TrainIdentifierId(identifier, operationDate, ru)
        )
        assertThat(result.startDateTime).isEqualTo(newStartTime)
    }
}
