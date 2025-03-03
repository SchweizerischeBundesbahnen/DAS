package ch.sbb.backend.servicepoints

import ch.sbb.backend.TestContainerConfiguration
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestContainerConfiguration::class)
class ServicePointsControllerTest {

    @Autowired
    protected lateinit var mockMvc: MockMvc

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
    fun `should respond with empty`() {
        mockMvc.perform(
            get("/api/v1/service-points")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.length()").value(0))
    }
}
