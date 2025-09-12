package ch.sbb.backend.formation;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@Import({TestContainerConfiguration.class})
@ActiveProfiles("test")
class FormationIntegrationTest {

    @Autowired
    private KafkaTemplate<DailyFormationTrainKey, DailyFormationTrain> kafkaTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private TrainFormationRunRepository repository;

    @Value("${zis.kafka.topic}")
    private String topic;

    @Test
    void listen_whenFormationMessage_shouldBeStored() throws IOException {
        DailyFormationTrainKey key = this.objectMapper.readValue(new File("src/test/resources/kafka/key.json"), DailyFormationTrainKey.class);
        DailyFormationTrain value = this.objectMapper.readValue(new File("src/test/resources/kafka/value.json"), DailyFormationTrain.class);

        kafkaTemplate.send(topic, key, value);

        await()
            .atMost(5, TimeUnit.SECONDS)
            .untilAsserted(() -> {
                List<TrainFormationRunEntity> saved = repository.findAll();
                assertThat(saved).hasSize(1);
                TrainFormationRunEntity actual = saved.getFirst();

                assertThat(actual.getId()).isEqualTo(1);
                assertThat(actual.getInspectionDateTime()).isEqualTo(OffsetDateTime.parse("2025-08-01T16:23:27Z"));
                assertThat(actual.getOperationalTrainNumber()).isEqualTo("71237");
                assertThat(actual.getTrainPathId()).isEqualTo("71237-001");
                assertThat(actual.getOperationalDay()).isEqualTo(LocalDate.parse("2025-08-01"));
                assertThat(actual.getCompany()).isEqualTo("2687");
                assertThat(actual.getTafTapLocationReferenceStart()).isEqualTo("CH05699");
                assertThat(actual.getTafTapLocationReferenceEnd()).isEqualTo("CH05683");
                assertThat(actual.getTrainCategoryCode()).isEqualTo("D");
                assertThat(actual.getBrakedWeightPercentage()).isEqualTo(75);
                assertThat(actual.getTractionMaxSpeedInKmh()).isEqualTo(100);
                assertThat(actual.getHauledLoadMaxSpeedInKmh()).isEqualTo(100);
                assertThat(actual.getFormationMaxSpeedInKmh()).isEqualTo(140);
                assertThat(actual.getTractionLengthInCm()).isEqualTo(1540);
                assertThat(actual.getHauledLoadLengthInCm()).isEqualTo(18800);
                assertThat(actual.getFormationLengthInCm()).isEqualTo(20340);
                assertThat(actual.getTractionWeightInT()).isEqualTo(84);
                assertThat(actual.getHauledLoadWeightInT()).isEqualTo(619);
                assertThat(actual.getFormationWeightInT()).isEqualTo(703);
                assertThat(actual.getTractionBrakedWeightInT()).isEqualTo(61);
                assertThat(actual.getHauledLoadBrakedWeightInT()).isEqualTo(482);
                assertThat(actual.getFormationBrakedWeightInT()).isEqualTo(543);
                assertThat(actual.getTractionHoldingForceInHectoNewton()).isEqualTo(500);
                assertThat(actual.getHauledLoadHoldingForceInHectoNewton()).isEqualTo(1852);
                assertThat(actual.getFormationHoldingForceInHectoNewton()).isEqualTo(2352);
                assertThat(actual.getBrakePositionGForLeadingTraction()).isNull();
                assertThat(actual.getBrakePositionGForBrakeUnit1to5()).isNull();
                assertThat(actual.getBrakePositionGForLoadHauled()).isNull();
                assertThat(actual.getSimTrain()).isFalse();
                assertThat(actual.getAdditionalTractions()).isEqualTo(List.of(""));
                assertThat(actual.getCarCarrierVehicle()).isFalse();
                assertThat(actual.getDangerousGoods()).isFalse();
                assertThat(actual.getVehiclesCount()).isEqualTo(11);
                assertThat(actual.getVehiclesWithBrakeDesignLlAndKCount()).isEqualTo(10);
                assertThat(actual.getVehiclesWithBrakeDesignDCount()).isEqualTo(0);
                assertThat(actual.getVehiclesWithDisabledBrakesCount()).isEqualTo(0);
                assertThat(actual.getEuropeanVehicleNumberFirst()).isEqualTo("338522222225");
                assertThat(actual.getEuropeanVehicleNumberLast()).isEqualTo("338514444445");
                assertThat(actual.getAxleLoadMaxInKg()).isEqualTo(22125);
                assertThat(actual.getRouteClass()).isEqualTo("");
                assertThat(actual.getGradientUphillMaxInPermille()).isEqualTo(0);
                assertThat(actual.getGradientDownhillMaxInPermille()).isEqualTo(0);
                assertThat(actual.getSlopeMaxForHoldingForceMinInPermille()).isEqualTo("21");
            });
    }
}
