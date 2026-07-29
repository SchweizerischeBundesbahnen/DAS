package ch.sbb.das.backend.cargo;

import static ch.sbb.das.backend.cargo.api.v1.FormationController.API_FORMATIONS;
import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.test.json.JsonCompareMode;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.json.JsonMapper;

@IntegrationTest
class FormationIntegrationTest {

    @Autowired
    private KafkaTemplate<DailyFormationTrainKey, DailyFormationTrain> kafkaTemplate;

    @Autowired
    private JsonMapper jsonMapper;

    @Autowired
    private MockMvc mockMvc;

    @Value("${formation.kafka.topic}")
    private String topic;

    @DisplayName("Inspected formation when received then it is available for the driver|tests:539,541,715,1176")
    @Test
    void whenNewInspectedFormationMessage_shouldBeAvailabe() throws IOException {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/71237/expected.json"));

        await()
            .atMost(5, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });
    }

    @DisplayName("Inspected formation when an updated version is received then the latest data replaces the previous version for the driver|tests:539,541,715,1176")
    @Test
    void whenUpdatedFormationMessage_shouldBeAvailabe() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        DailyFormationTrain updatedValue = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_value_update.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/71237/expected_update.json"));

        await()
            .atMost(5, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });
    }

    @DisplayName("Formation when a non-inspected update is received then the cached formation remains unchanged|tests:539,541,715,1176")
    @Test
    void whenUpdatedNonInpsectedFormationMessage_shouldNotHaveUpdateByEtag() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/71237/expected.json"));
        AtomicReference<String> eTag = new AtomicReference<>();

        await()
            .atMost(10, TimeUnit.SECONDS)
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

        DailyFormationTrain updatedValue = this.jsonMapper.readValue(new File("src/test/resources/cargo/71237/kafka_value_update_non_inspected.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        await()
            .atMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "71237").param("operationalDay", "2025-08-01").param("company", "2687")
                        .header(HttpHeaders.IF_NONE_MATCH, eTag.get())
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotModified());
            });

    }

    @DisplayName("Formation when it is not inspected then it is not served to drivers|tests:539,541,715,1176")
    @Test
    void whenNonInspectedFormationMessage_shouldNotBeAvailabe() {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/11/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/11/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        await()
            .atMost(5, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "11").param("operationalDay", "2025-08-01").param("company", "1111")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotFound());
            });
    }

    @DisplayName("Formation when train runs change then the updated train run details are available for the driver|tests:539,541,715,1176")
    @Test
    void whenUpdatedFormationRunsMessage_shouldBeAvailabe() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/87389/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/87389/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value).get(10, TimeUnit.SECONDS);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/87389/expected.json"));
        await()
            .atMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "87389").param("operationalDay", "2025-08-05").param("company", "6382")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });

        DailyFormationTrain updatedValue = this.jsonMapper.readValue(new File("src/test/resources/cargo/87389/kafka_value_update.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, updatedValue);

        String expectedUpdatedJson = Files.readString(Paths.get("src/test/resources/cargo/87389/expected_update.json"));
        await()
            .atMost(15, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "87389").param("operationalDay", "2025-08-05").param("company", "6382")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedUpdatedJson, JsonCompareMode.STRICT));
            });
    }

    @DisplayName("Formation when a minimal message is received then it is processed without errors|tests:539,541,715,1176")
    @Test
    void whenNewMinimalFormationMessage_shouldNotFail() throws IOException {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/43/expected.json"));

        await()
            .atMost(5, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "43").param("operationalDay", "2025-11-18").param("company", "3412")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
            });
    }

    @DisplayName("Formation when smsEvu is not 4 chars then the kafka message is ignored|tests:539,541,715,1176")
    @Test
    void whenFormationMessageHasInvalidCompanyLength_shouldNotBeAvailable() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_value.json"), DailyFormationTrain.class);

        key.setZugnummer(99431);
        key.setBetriebstag(java.time.LocalDate.of(2025, 11, 19));
        key.setTrassenId("99431-001");

        value.getFormationRuns().getFirst().setSmsEvu("123");
        if (value.getKey() != null) {
            value.getKey().setZugnummer(99431);
            value.getKey().setBetriebstag(java.time.LocalDate.of(2025, 11, 19));
            value.getKey().setTrassenId("99431-001");
        }

        kafkaTemplate.send(topic, key, value).get(10, TimeUnit.SECONDS);

        await()
            .atMost(10, TimeUnit.SECONDS)
            .during(3, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "99431").param("operationalDay", "2025-11-19").param("company", "1234")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotFound());
            });
    }

    @DisplayName("Formation when smsEvu is null then the kafka message is ignored|tests:539,541,715,1176")
    @Test
    void whenFormationMessageHasNullCompany_shouldNotBeAvailable() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_value.json"), DailyFormationTrain.class);

        key.setZugnummer(99432);
        key.setBetriebstag(LocalDate.of(2025, 11, 20));
        key.setTrassenId("99432-001");

        value.getFormationRuns().getFirst().setSmsEvu(null);
        if (value.getKey() != null) {
            value.getKey().setZugnummer(99432);
            value.getKey().setBetriebstag(LocalDate.of(2025, 11, 20));
            value.getKey().setTrassenId("99432-001");
        }

        kafkaTemplate.send(topic, key, value).get(10, TimeUnit.SECONDS);

        await()
            .atMost(10, TimeUnit.SECONDS)
            .during(3, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "99432").param("operationalDay", "2025-11-20").param("company", "1234")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isNotFound());
            });
    }

    @DisplayName("Formation when one run has invalid smsEvu then only that run is skipped|tests:539,541,715,1176")
    @Test
    void whenMessageContainsMixedValidAndInvalidCompanies_shouldKeepOnlyValidRuns() throws Exception {
        DailyFormationTrainKey key = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.jsonMapper.readValue(new File("src/test/resources/cargo/43/kafka_value.json"), DailyFormationTrain.class);

        key.setZugnummer(99433);
        key.setBetriebstag(java.time.LocalDate.of(2025, 11, 21));
        key.setTrassenId("99433-001");

        ch.sbb.zis.trainformation.api.model.FormationRun validRun = value.getFormationRuns().getFirst();
        ch.sbb.zis.trainformation.api.model.FormationRun invalidRun = this.jsonMapper.readValue(
            this.jsonMapper.writeValueAsBytes(validRun),
            ch.sbb.zis.trainformation.api.model.FormationRun.class
        );
        invalidRun.setSmsEvu("123");
        value.setFormationRuns(List.of(invalidRun, validRun));

        if (value.getKey() != null) {
            value.getKey().setZugnummer(99433);
            value.getKey().setBetriebstag(java.time.LocalDate.of(2025, 11, 21));
            value.getKey().setTrassenId("99433-001");
        }

        kafkaTemplate.send(topic, key, value).get(10, TimeUnit.SECONDS);

        await()
            .atMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                mockMvc.perform(get(API_FORMATIONS)
                        .param("operationalTrainNumber", "99433").param("operationalDay", "2025-11-21").param("company", "3412")
                        .with(user("any").roles("observer")))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data[0].company").value("3412"))
                    .andExpect(jsonPath("$.data[0].formationRuns.length()").value(1))
                    .andExpect(jsonPath("$.data[0].formationRuns[0].tafTapLocationReferenceStart").value("CH05699"))
                    .andExpect(jsonPath("$.data[0].formationRuns[0].tafTapLocationReferenceEnd").value("CH05683"));
            });
    }
}
