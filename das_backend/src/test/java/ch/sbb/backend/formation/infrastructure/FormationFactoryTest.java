package ch.sbb.backend.formation.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;

import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.time.LocalDate;
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

        DailyFormationTrain value = new DailyFormationTrain();
        ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message =
            new ConsumerRecord<>("topic", 0, 0L, key, value);

        try (MockedStatic<FormationRunFactory> mockedStatic = mockStatic(FormationRunFactory.class)) {
            Formation result = FormationFactory.create(message);

            assertThat(result.getOperationalTrainNumber()).isEqualTo(operationalTrainNumber.toString());
            assertThat(result.getOperationalDay()).isEqualTo(operationalDay);
            mockedStatic.verify(() -> FormationRunFactory.create(any()), times(1));
        }
    }
}