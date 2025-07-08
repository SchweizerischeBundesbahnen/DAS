package ch.sbb.backend.formation.infrastructure.trainformation;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

import ch.sbb.backend.formation.domain.TrainFormationService;
import ch.sbb.backend.formation.domain.model.TrainFormationRun;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import ch.sbb.zis.trainformation.api.model.FormationRun;
import ch.sbb.zis.trainformation.api.model.FormationRunInspection;
import ch.sbb.zis.trainformation.api.model.TrainMetadata;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class TrainFormationKafkaConsumerTest {

    private TrainFormationService service;
    private TrainFormationKafkaConsumer underTest;

    @BeforeEach
    void setUp() {
        Mockito.mockConstruction(TrainFormationRun.class);
        service = mock(TrainFormationService.class);
        underTest = new TrainFormationKafkaConsumer(service);
    }

    @Test
    void testReceive_withInspectedFormationRun_callsService() {
        // Arrange
        DailyFormationTrainKey key = new DailyFormationTrainKey();
        key.setBetriebstag(LocalDate.now().toString());
        key.setZugnummer(123);

        TrainMetadata metadata = new TrainMetadata();
        metadata.setModifiedDateTime(Date.from(Instant.now()));

        FormationRunInspection inspected = new FormationRunInspection();
        inspected.setInspected(true);

        FormationRun formationRun1 = new FormationRun();
        formationRun1.setFormationRunInspection(inspected);

        FormationRunInspection nonInspected = new FormationRunInspection();
        nonInspected.setInspected(false);

        FormationRun formationRun2 = new FormationRun();
        formationRun2.setFormationRunInspection(nonInspected);

        DailyFormationTrain value = new DailyFormationTrain();
        value.setMetadata(metadata);
        value.setFormationRuns(List.of(formationRun1, formationRun2));

        ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> record =
            new ConsumerRecord<>("topic", 0, 0L, key, value);

        // Act
        underTest.receive(record);

        // Assert
        //        todo check key and the stuff except TrainFormationRun
        verify(service, times(1)).processTrainFormationRun(any());

    }

    @Test
    void testReceive_withNullFormationRuns_doesNotCallService() {
        // Arrange
        DailyFormationTrainKey key = new DailyFormationTrainKey();
        key.setBetriebstag(LocalDate.now().toString());
        key.setZugnummer(123);

        DailyFormationTrain value = new DailyFormationTrain();
        value.setFormationRuns(null);

        ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> record =
            new ConsumerRecord<>("topic", 0, 0L, key, value);

        // Act
        underTest.receive(record);

        // Assert
        verifyNoInteractions(service);
    }
}