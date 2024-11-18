package ch.sbb.backend.infrastructure.repositories

import ch.sbb.backend.application.rest.ServicePointDto
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import kotlin.jvm.optionals.getOrNull

@Repository
class ServicePointsRepository(private val jdbcClient: JdbcClient) {

    fun update(servicePoints: List<ServicePointDto>) {
        val sql = """
            INSERT INTO service_points (uic, designation, abbreviation)
            VALUES (:uic, :designation, :abbreviation)
            ON CONFLICT (uic) DO UPDATE SET
                designation = EXCLUDED.designation,
                abbreviation = EXCLUDED.abbreviation
        """.trimIndent()

        servicePoints.forEach {
            jdbcClient.sql(sql)
                .param("uic", it.uic)
                .param("designation", it.designation)
                .param("abbreviation", it.abbreviation)
                .update()
        }
    }

    fun getAll(): List<ServicePointDto> {
        return jdbcClient.sql("SELECT uic,designation,abbreviation FROM service_points")
            .query(ServicePointDto::class.java)
            .list()
    }

    fun getByUic(uic: Int): ServicePointDto? {
        return jdbcClient.sql("SELECT uic,designation,abbreviation FROM service_points WHERE uic = :uic")
            .param("uic", uic)
            .query(ServicePointDto::class.java)
            .optional().getOrNull()
    }
}
