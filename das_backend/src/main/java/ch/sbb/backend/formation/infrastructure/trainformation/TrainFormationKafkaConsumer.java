package ch.sbb.backend.formation.infrastructure.trainformation;

import ch.sbb.backend.formation.domain.TrainFormationService;
import ch.sbb.backend.formation.domain.model.TrainFormationRun;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrain;
import ch.sbb.zis.trainformation.api.model.DailyFormationTrainKey;
import ch.sbb.zis.trainformation.api.model.FormationRunInspection;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TrainFormationKafkaConsumer {

    private final TrainFormationService trainFormationService;

    public TrainFormationKafkaConsumer(TrainFormationService trainFormationService) {
        this.trainFormationService = trainFormationService;
    }

    //    todo env
    @KafkaListener(topics = "zis.inte.trafo.trainformation.operational")
    void receive(ConsumerRecord<DailyFormationTrainKey, DailyFormationTrain> message) {
        if (message.value().getFormationRuns() == null) {
            log.warn("Received message with null formation runs: {}", message);
            return;
        }
        message.value().getFormationRuns()
            .stream()
            .filter(formationRun -> {
                FormationRunInspection formationRunInspection = formationRun.getFormationRunInspection();
                return formationRunInspection != null && formationRunInspection.getInspected();
            })
            .forEach(formationRun -> trainFormationService.processTrainFormationRun(new TrainFormationRun(
                LocalDateTime.ofInstant(message.value().getMetadata().getModifiedDateTime().toInstant(), ZoneId.systemDefault()),
                LocalDate.parse(message.key().getBetriebstag()),
                message.key().getZugnummer().toString(),
                formationRun)));
    }
}
