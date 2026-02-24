package ch.sbb.backend;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@IntegrationTest
@AutoConfigureMockMvc(addFilters = false)
@Slf4j
class ApiExtractionTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void shouldProvideApiYaml() throws Exception {
        MvcResult mvcResult = mvc.perform(get("/v3/api-docs.yaml"))
            .andExpect(status().isOk())
            .andReturn();
        Path specYamlFile = Paths.get("src/main/resources/api/api-specification.yaml");

        Path parentDir = specYamlFile.getParent();
        assertThat(parentDir).isNotNull();
        if (!Files.exists(parentDir)) {
            Files.createDirectories(parentDir);
        }

        log.info("Exporting OpenAPI api-specification.yaml to {}", specYamlFile.toAbsolutePath().normalize());

        byte[] specYamlAsBytes = mvcResult.getResponse().getContentAsByteArray();
        assertThat(specYamlAsBytes).isNotEmpty();

        Files.write(specYamlFile, specYamlAsBytes);
    }

}
