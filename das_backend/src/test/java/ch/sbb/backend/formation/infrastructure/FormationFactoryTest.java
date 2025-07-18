package ch.sbb.backend.formation.infrastructure;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;

import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import ch.sbb.zis.trainformation.api.model.TrainMetadata;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

class FormationFactoryTest {

    @Test
    void create() {
        LocalDate operationalDay = LocalDate.now();
        Integer operationalTrainNumber = 123;
        DailyFormationTrainKey key = new DailyFormationTrainKey();
        key.setBetriebstag(operationalDay);
        key.setZugnummer(operationalTrainNumber);

        OffsetDateTime modifiedDateTime = OffsetDateTime.now();
        TrainMetadata metadata = new TrainMetadata();
        metadata.setModifiedDateTime(modifiedDateTime);

        DailyFormationTrain value = new DailyFormationTrain();
        value.setMetadata(metadata);
        ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message =
            new ConsumerRecord<>("topic", 0, 0L, key, value);

        try (MockedStatic<FormationRunFactory> mockedStatic = mockStatic(FormationRunFactory.class)) {
            Formation result = FormationFactory.create(message);

            assertEquals(modifiedDateTime, result.getModifiedDateTime());
            assertEquals(operationalTrainNumber.toString(), result.getOperationalTrainNumber());
            assertEquals(operationalDay, result.getOperationalDay());
            mockedStatic.verify(() -> FormationRunFactory.create(any()), times(1));
        }
    }
}