package ch.sbb.backend.application.rest

import org.junit.jupiter.api.Test
import org.springframework.http.MediaType
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status


class ServicePointsControllerTest : BaseIT() {

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should update and find service point`() {
        val servicePointsJson = """
            [
              {
                "uic": 8518771,
                "designation": "Biel/Bienne Bözingenfeld/Champ",
                "abbreviation": "BIBD"
              }
            ]
        """.trimIndent()

        mockMvc.perform(
            put("/api/v1/service-points")
                .contentType(MediaType.APPLICATION_JSON)
                .content(servicePointsJson)
        )
            .andExpect(status().isOk)

        mockMvc.perform(
            get("/api/v1/service-points/8518771")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.uic").value(8518771))
            .andExpect(jsonPath("$.designation").value("Biel/Bienne Bözingenfeld/Champ"))
            .andExpect(jsonPath("$.abbreviation").value("BIBD"))
    }

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should update and find all service point`() {
        val servicePointsJson = """
            [
              {
                "uic": 8518771,
                "designation": "Biel/Bienne Bözingenfeld/Champ",
                "abbreviation": "BIBD"
              },
              {
                "uic": 8583629,
                "designation": "Hinterhunziken",
                "abbreviation": "HHZ"
              }
            ]
        """.trimIndent()

        mockMvc.perform(
            put("/api/v1/service-points")
                .contentType(MediaType.APPLICATION_JSON)
                .content(servicePointsJson)
        )
            .andExpect(status().isOk)

        mockMvc.perform(
            get("/api/v1/service-points")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].uic").value(8518771))
            .andExpect(jsonPath("$[0].designation").value("Biel/Bienne Bözingenfeld/Champ"))
            .andExpect(jsonPath("$[0].abbreviation").value("BIBD"))
            .andExpect(jsonPath("$[1].uic").value(8583629))
            .andExpect(jsonPath("$[1].designation").value("Hinterhunziken"))
            .andExpect(jsonPath("$[1].abbreviation").value("HHZ"))
    }

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should update existing service points`() {
        val servicePointsJson = """
            [
              {
                "uic": 8518771,
                "designation": "Biel/Bienne Bözingenfeld/Champ",
                "abbreviation": "BIBD"
              },
              {
                "uic": 8583629,
                "designation": "Hinterhunziken",
                "abbreviation": "HHZ"
              }
            ]
        """.trimIndent()

        mockMvc.perform(
            put("/api/v1/service-points")
                .contentType(MediaType.APPLICATION_JSON)
                .content(servicePointsJson)
        )
            .andExpect(status().isOk)


        val updatedServicePointJson = """
            [
              {
                "uic": 8518771,
                "designation": "Biel/Bienne Bözingenfeld",
                "abbreviation": "BIBD"
              }
            ]
        """.trimIndent()

        mockMvc.perform(
            put("/api/v1/service-points")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updatedServicePointJson)
        )
            .andExpect(status().isOk)

        mockMvc.perform(
            get("/api/v1/service-points")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].uic").value(8583629))
            .andExpect(jsonPath("$[0].designation").value("Hinterhunziken"))
            .andExpect(jsonPath("$[0].abbreviation").value("HHZ"))
            .andExpect(jsonPath("$[1].uic").value(8518771))
            .andExpect(jsonPath("$[1].designation").value("Biel/Bienne Bözingenfeld"))
            .andExpect(jsonPath("$[1].abbreviation").value("BIBD"))
    }

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should respond with not found`() {
        mockMvc.perform(
            get("/api/v1/service-points/11111")
        )
            .andExpect(status().isNotFound)
    }

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should respond with bad request`() {
        val servicePointsJson = """
            [
              {
                "uic": 8518771,
                "designation": "Biel/Bienne Bözingenfeld/Champ"
              }
            ]
        """.trimIndent()

        mockMvc.perform(
            put("/api/v1/service-points")
                .contentType(MediaType.APPLICATION_JSON)
                .content(servicePointsJson)
        )
            .andExpect(status().isBadRequest)
    }
}
