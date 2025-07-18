package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.application.FormationService;
import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TrainFormationKafkaConsumer {

    private final FormationService formationService;

    public TrainFormationKafkaConsumer(FormationService formationService) {
        this.formationService = formationService;
    }

    @KafkaListener(topics = "${zis.kafka.topic}")
    void receive(ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        Formation formation = FormationFactory.create(message);
        List<TrainFormationRunEntity> trainFormationRunEntity = TrainFormationRunEntity.from(formation);
        formationService.save(trainFormationRunEntity);
    }
}
