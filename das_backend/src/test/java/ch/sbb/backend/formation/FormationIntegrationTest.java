package ch.sbb.backend.formation;

import static ch.sbb.backend.formation.api.v1.FormationController.API_FORMATIONS;
import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.json.JsonCompareMode;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@Import({TestContainerConfiguration.class})
@AutoConfigureMockMvc
@ActiveProfiles("test")
class FormationIntegrationTest {

    @Autowired
    private KafkaTemplate<DailyFormationTrainKey, DailyFormationTrain> kafkaTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private MockMvc mockMvc;

    @Value("${zis.kafka.topic}")
    private String topic;

    @Test
    void whenNewInspectedFormationMessage_shouldBeAvailabe() throws IOException {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/71237.json"));

        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });
    }

    @Test
    void whenUpdatedFormationMessage_shouldBeAvailabe() throws Exception {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        DailyFormationTrain updatedValue = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/value_update.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/71237_update.json"));

        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });
    }

    @Test
    void whenUpdatedNonInpsectedFormationMessage_shouldNotHaveUpdateByEtag() throws Exception {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/71237.json"));
        AtomicReference<String> eTag = new AtomicReference<>();

        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT))
                    .andDo(result -> {
                        eTag.set(result.getResponse().getHeader(HttpHeaders.ETAG));
                        assertThat(eTag.get()).isNotNull();
                    });
            });

        mockMvc.perform(get(API_FORMATIONS)
                .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                .header(HttpHeaders.IF_NONE_MATCH, eTag.get())
                .with(user("any").roles("observer")))
            .andExpect(status().isNotModified());

        DailyFormationTrain updatedValue = this.objectMapper.readValue(new File("src/test/resources/kafka/71237/value_update_non_inspected.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .header(HttpHeaders.IF_NONE_MATCH, eTag.get())
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotModified());
            });

    }

    @Test
    void whenNonInspectedFormationMessage_shouldNotBeAvailabe() throws IOException {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/11/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/11/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "11").param("operationalDay", "2025-08-01").param("company", "1111")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotFound());
            });
    }

    @Test
    void whenUpdatedFormationRunsMessage_shouldBeAvailabe() throws Exception {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/87389/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/87389/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/87389.json"));
        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "87389").param("operationalDay", "2025-08-05").param("company", "6382")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });

        DailyFormationTrain updatedValue = this.objectMapper.readValue(new File("src/test/resources/kafka/87389/value_update.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        String expectedUpdatedJson = Files.readString(Paths.get("src/test/resources/formations/87389_update.json"));
        await()
            .atMost(1, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "87389").param("operationalDay", "2025-08-05").param("company", "6382")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedUpdatedJson, JsonCompareMode.STRICT));
            });
    }
}
