package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.TimetableService;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainKey;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainValue;
import ch.sbb.backend.preload.infrastructure.util.KafkaDeserializer;
import ch.sbb.backend.preload.infrastructure.util.ListUtil;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.utils.Bytes;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

@Component
@Slf4j
public class TimetableTrainConsumer {

    private static final String VERSTAENDIGTE_TRASSEN_KEY_SUFFIX = "_VT";

    private final KafkaDeserializer<TimetableTrainKey, TimetableTrainValue> deserializer;

    private final TimetableService timetableService;

    public TimetableTrainConsumer(JsonMapper objectMapper, TimetableService timetableService) {
        this.deserializer = new KafkaDeserializer<>(objectMapper, TimetableTrainKey.class, TimetableTrainValue.class);
        this.timetableService = timetableService;
    }

    @KafkaListener(
        id = "consumeTrains",
        containerFactory = "timetableListenerContainerFactory",
        groupId = "${spring.kafka.consumer.group-id}",
        topics = "${preload.timetableTrain.topic}",
        batch = "true",
        autoStartup = "false"
    )
    public void consume(List<ConsumerRecord<Bytes, Bytes>> records) {

        List<ConsumerRecord<Bytes, Bytes>> recordsWithVtSuffix = records.stream()
            .filter(rec -> deserializer.deserializeKey(rec).getId().endsWith(VERSTAENDIGTE_TRASSEN_KEY_SUFFIX))
            .toList();

        List<ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> filteredTrains = filterAndDeserialize(recordsWithVtSuffix);
        List<ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> distinctRecords = ListUtil.removeDuplicatesKeepLast(filteredTrains, this::getTrassendIdAndFahrplanPeriode);

        log.debug("{} records with {} valid trains, last offset: {}",
            records.size(),
            recordsWithVtSuffix.size(),
            records.isEmpty() ? "n/a" : records.getLast().offset());
        timetableService.deleteOrSaveTrains(distinctRecords);
    }

    private Map.Entry<String, Integer> getTrassendIdAndFahrplanPeriode(ConsumerRecord<TimetableTrainKey, TimetableTrainValue> message) {
        return Map.entry(message.value().getTrassenID(), message.value().getFahrplanperiode());
    }

    private List<ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> filterAndDeserialize(List<ConsumerRecord<Bytes, Bytes>> consumerRecords) {
        return consumerRecords.stream()
            .map(deserializer::deserializeRecord)
            .filter(rec -> validTrain(rec.value()))
            .filter(rec -> rec.value().getFahrplanperiode() >= LocalDate.now().getYear())
            .toList();
    }

    private boolean validTrain(TimetableTrainValue zug) {
        return zug != null && TimetableTrainValue.Sicht.VT.equals(zug.getSicht());
    }
}
