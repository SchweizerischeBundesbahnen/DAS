package ch.sbb.backend.preload;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.waitAtMost;

import ch.sbb.backend.IntegrationTest;
import ch.sbb.backend.preload.application.TimetableService;
import ch.sbb.backend.preload.application.TrainIdentificationService;
import ch.sbb.backend.preload.application.model.trainidentification.CompanyCode;
import ch.sbb.backend.preload.application.model.trainidentification.TimetablePeriod;
import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.TimetablePeriodRepository;
import ch.sbb.backend.preload.infrastructure.model.period.TimetablePeriodKey;
import ch.sbb.backend.preload.infrastructure.model.period.TimetablePeriodValue;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainKey;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainValue;
import ch.sbb.backend.preload.infrastructure.util.Coordinator;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import tools.jackson.databind.json.JsonMapper;

@IntegrationTest
class TrainIdentificationIntegrationTest {

    private static final int TEST_PERIOD_NUMBER_OF_DAYS = 10;
    private static final CompanyCode COMPANY_CODE_SOB = CompanyCode.of("5458");

    @Autowired
    private JsonMapper jsonMapper;

    @Autowired
    private Coordinator coordinator;

    @Autowired
    private TimetablePeriodRepository timetablePeriodRepository;

    @Autowired
    private TrainIdentificationService trainIdentificationService;

    @Autowired
    private TimetableService timetableService;

    @Autowired
    private KafkaTemplate<Object, Object> kafkaTemplate;

    @Value("${preload.timetablePeriod.topic}")
    private String timetablePeriodTopic;

    @Value("${preload.timetableTrain.topic}")
    private String timetableTrainTopic;

    @Test
    void publishNetsPeriod__timetablePeriodSaved() {
        TimetablePeriodKey key = jsonMapper.readValue(new File("src/test/resources/kafka/period/key.json"), TimetablePeriodKey.class);
        TimetablePeriodValue value = jsonMapper.readValue(new File("src/test/resources/kafka/period/value.json"), TimetablePeriodValue.class);
        int testYear = 2025;

        // When
        kafkaTemplate.send(timetablePeriodTopic, key, value);

        // Then
        waitAtMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> assertThat(timetablePeriodRepository.findById(testYear))
                .hasValueSatisfying(actual ->
                    assertThat(actual)
                        .usingRecursiveComparison()
                        .isEqualTo(TimetablePeriod.builder()
                            .year(testYear)
                            .firstDay(LocalDate.of(testYear, 1, 1))
                            .lastDay(LocalDate.of(testYear, 1, 1 + TEST_PERIOD_NUMBER_OF_DAYS))
                            .build())
                ));
    }

    @Test
    void saveAndDeleteTrainData() {

        // Given
        coordinator.startProcessing();

        // When

        // period starts Jan 1st
        TimetablePeriodKey periodKey = jsonMapper.readValue(new File("src/test/resources/kafka/period/key_future.json"), TimetablePeriodKey.class);
        TimetablePeriodValue periodValue = jsonMapper.readValue(new File("src/test/resources/kafka/period/value_future.json"), TimetablePeriodValue.class);
        int testYear = 2099;

        kafkaTemplate.send(timetablePeriodTopic, periodKey, periodValue);

        // Then
        waitAtMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> assertThat(timetablePeriodRepository.findById(testYear))
                .hasValueSatisfying(actual ->
                    assertThat(actual)
                        .usingRecursiveComparison()
                        .isEqualTo(TimetablePeriod.builder()
                            .year(testYear)
                            .firstDay(LocalDate.of(testYear, 1, 1))
                            .lastDay(LocalDate.of(testYear, 1, 1 + TEST_PERIOD_NUMBER_OF_DAYS))
                            .build())
                ));

        // When
        TimetableTrainKey fpsKey = jsonMapper.readValue(new File("src/test/resources/kafka/trainIdentification/key.json"), TimetableTrainKey.class);
        TimetableTrainValue fpsTrain = jsonMapper.readValue(new File("src/test/resources/kafka/trainIdentification/value.json"), TimetableTrainValue.class);

        // When
        sendRecord(fpsKey, fpsTrain);

        LocalDate startDate = LocalDate.of(testYear, 1, 2);

        // Then
        waitAtMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                List<TrainIdentification> trainIds = trainIdentificationService.processDailyTrainRunRequest(OffsetDateTime.of(startDate.plusDays(1), LocalTime.now(), ZoneOffset.UTC));
                assertThat(trainIds).hasSize(1);
                TrainIdentification trainId = trainIds.getFirst();
                assertThat(trainId.startDate()).isEqualTo(startDate);
                assertThat(trainId.operationalTrainNumber()).isEqualTo("728");
                assertThat(trainId.companies()).containsExactly(COMPANY_CODE_SOB);
            });

        // When
        timetableService.deleteObsoleteData(LocalDate.of(testYear, 2, 25));

        // Then
        waitAtMost(10, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                List<TrainIdentification> trainIds = trainIdentificationService.processDailyTrainRunRequest(OffsetDateTime.of(startDate.plusDays(1), LocalTime.now(), ZoneOffset.UTC));
                assertThat(trainIds).isEmpty();
            });
    }

    private void sendRecord(Object key, Object train) {
        ProducerRecord<Object, Object> producerRecord = new ProducerRecord<>(timetableTrainTopic, null, key, train);
        producerRecord.headers().add("eventType", "UPDATE".getBytes(StandardCharsets.UTF_8));
        kafkaTemplate.send(producerRecord);
    }
}
