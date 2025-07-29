package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import org.apache.kafka.clients.consumer.ConsumerRecord;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class FormationFactory {

    public static Formation create(ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        LocalDate operationalDay = message.key().getBetriebstag();
        String operationalTrainNumber = message.key().getZugnummer().toString();
        DailyFormationTrain dailyFormationTrain = message.value();
        OffsetDateTime modifiedDateTime = dailyFormationTrain.getMetadata().getModifiedDateTime();
        return new Formation(modifiedDateTime, operationalTrainNumber, operationalDay, FormationRunFactory.create(dailyFormationTrain.getFormationRuns()));
    }
}
