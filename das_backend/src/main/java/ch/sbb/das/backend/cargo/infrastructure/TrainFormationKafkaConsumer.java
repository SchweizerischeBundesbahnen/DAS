package ch.sbb.das.backend.cargo.infrastructure;

import ch.sbb.das.backend.cargo.application.FormationService;
import ch.sbb.das.backend.cargo.domain.model.Formation;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.LogKeys;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.spi.LoggingEventBuilder;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

/**
 * Datasource: ZIS-Formation
 *
 * @see <a href="https://developer.sbb.ch/apis/zis-prod-trafo-internal-aws/information">TrainFormation data products async API</a>
 */
@Service
@Slf4j
public class TrainFormationKafkaConsumer {

    private final FormationService formationService;
    private final TrainFormationRunEntityMapper trainFormationRunEntityMapper;

    public TrainFormationKafkaConsumer(FormationService formationService, TrainFormationRunEntityMapper trainFormationRunEntityMapper) {
        this.formationService = formationService;
        this.trainFormationRunEntityMapper = trainFormationRunEntityMapper;
    }

    @KafkaListener(topics = "${formation.kafka.topic}", groupId = "${formation.kafka.group-id}", autoStartup = "${formation.kafka.enabled:true}", containerFactory = "trainFormationListenerContainerFactory")
    void receive(ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        long lagInS = (DateTimeUtil.now().toInstant().toEpochMilli() - message.timestamp()) / 1000;
        withRecord(log.atTrace(), message).addKeyValue("lagSeconds", lagInS).log("Train formation record received");
        if (message.value() == null) {
            withRecord(log.atDebug(), message).log("Train formation tombstone skipped");
            return;
        }
        try {
            Formation formation = FormationFactory.create(message);
            List<TrainFormationRunEntity> trainFormationRunEntities = trainFormationRunEntityMapper.toEntities(formation);

            formationService.deleteAndSave(formation.getTrainPathId(), formation.getOperationalDay(), trainFormationRunEntities);
            withRecord(log.atDebug(), message).log("Train formation saved");
        } catch (Exception e) {
            withRecord(log.atError().setCause(e), message).log("Train formation record failed");
        }
    }

    private static LoggingEventBuilder withRecord(LoggingEventBuilder builder, ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        return builder
            .addKeyValue(LogKeys.KAFKA_PARTITION, message.partition())
            .addKeyValue(LogKeys.KAFKA_OFFSET, message.offset())
            .addKeyValue(LogKeys.TRAIN_NUMBER, message.key().getZugnummer())
            .addKeyValue(LogKeys.OPERATIONAL_DAY, message.key().getBetriebstag());
    }
}
