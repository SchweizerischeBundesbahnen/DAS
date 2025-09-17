package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.application.FormationService;
import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.time.Instant;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.event.Level;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TrainFormationKafkaConsumer {

    private final FormationService formationService;

    @Value("${zis.lag-alert-threshold-seconds:60}")
    private long lagAlertThresholdSeconds;

    public TrainFormationKafkaConsumer(FormationService formationService) {
        this.formationService = formationService;
    }

    @KafkaListener(topics = "${zis.kafka.topic}")
    void receive(ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        long lagInS = (Instant.now().toEpochMilli() - message.timestamp()) / 1000;
        log.atLevel(lagInS > lagAlertThresholdSeconds ? Level.WARN : Level.DEBUG).log("lagInS={} partition={} offset={}", lagInS, message.partition(), message.offset());
        try {
            Formation formation = FormationFactory.create(message);
            List<TrainFormationRunEntity> trainFormationRunEntities = TrainFormationRunEntity.from(formation);

            formationService.deleteByTrainPathIdAndOperationalDay(formation.getTrainPathId(), formation.getOperationalDay());
            formationService.save(trainFormationRunEntities);
            log.debug("Train formation runs saved from kafka message partition={}, offset={}", message.partition(), message.offset());
        } catch (Exception e) {
            log.error("Error processing kafka message partition={}, offset={}, operationalTrainNumber={}, operationalDay={}", message.partition(), message.offset(), message.key().getZugnummer(),
                message.key().getBetriebstag(), e);
        }
    }
}
