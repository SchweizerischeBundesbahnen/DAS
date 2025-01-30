package ch.sbb.backend.servicepoints

import ch.sbb.backend.BaseIT
import org.junit.jupiter.api.Test
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status


class ServicePointsControllerTest : BaseIT() {

    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should respond with not found`() {
        println("postgres testcontainer url: ${postgres.jdbcUrl}")
        mockMvc.perform(
            get("/api/v1/service-points/11111")
        )
            .andExpect(status().isNotFound)
    }


    @Test
    @WithMockUser(authorities = ["ROLE_admin"])
    fun `should respond with empty`() {
        mockMvc.perform(
            get("/api/v1/service-points")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.length()").value(0))
    }
}
