package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.model.trainidentification.TimetablePeriod;
import ch.sbb.backend.preload.infrastructure.model.period.TimetablePeriodKey;
import ch.sbb.backend.preload.infrastructure.model.period.TimetablePeriodValue;
import ch.sbb.backend.preload.infrastructure.util.Coordinator;
import ch.sbb.backend.preload.infrastructure.util.KafkaDeserializer;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicBoolean;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.utils.Bytes;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.PartitionOffset;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

@Component
@Slf4j
public class TimetablePeriodConsumer {

    private final KafkaDeserializer<TimetablePeriodKey, TimetablePeriodValue> deserializer;
    private final TimetablePeriodRepository timetablePeriodRepository;

    private final Coordinator coordinator;

    private Optional<Long> endOffset = Optional.empty();

    private final AtomicBoolean coordinatorStarted = new AtomicBoolean(false);

    public TimetablePeriodConsumer(JsonMapper objectMapper, TimetablePeriodRepository timetablePeriodRepository, Coordinator coordinator) {
        deserializer = new KafkaDeserializer<>(objectMapper, TimetablePeriodKey.class,
            TimetablePeriodValue.class);

        this.timetablePeriodRepository = timetablePeriodRepository;
        this.coordinator = coordinator;
    }

    @KafkaListener(
        batch = "true",
        containerFactory = "timetableListenerContainerFactory",
        groupId = "${spring.kafka.consumer.group-id}",
        topicPartitions = @org.springframework.kafka.annotation.TopicPartition(
            topic = "${preload.timetablePeriod.topic}",
            partitionOffsets = {@PartitionOffset(partition = "0", initialOffset = "0")}
        )
    )
    public void processTimetablePeriods(List<ConsumerRecord<Bytes, Bytes>> records, Consumer<?, ?> consumer) {

        log.info("received {} records",
            records.size());

        records.forEach(message -> processTimetablePeriod(message, consumer));
    }

    private void processTimetablePeriod(ConsumerRecord<Bytes, Bytes> message, Consumer<?, ?> consumer) {
        if (endOffset.isEmpty()) {
            endOffset = fetchEndOffset(message, consumer);
        }

        ConsumerRecord<TimetablePeriodKey, TimetablePeriodValue> convertedRecord = deserializer.deserializeRecord(message);

        TimetablePeriod timetablePeriod = convert(convertedRecord.value());

        log.info("save timetable period {}", timetablePeriod);
        timetablePeriodRepository.add(timetablePeriod);

        if (endOffset.isPresent() && !coordinatorStarted.get()) {
            Long currentOffset = message.offset();
            if (currentOffset.equals(endOffset.get() - 1)) {
                log.info("All timetablePeriods read, starting processing.");
                coordinator.startProcessing();
                coordinatorStarted.set(true);
            }
        }
    }

    private Optional<Long> fetchEndOffset(ConsumerRecord<Bytes, Bytes> message, Consumer<?, ?> consumer) {
        TopicPartition topicPartition = new TopicPartition(message.topic(), message.partition());
        Map<TopicPartition, Long> endOffsets = consumer.endOffsets(Collections.singleton(topicPartition));
        return Optional.ofNullable(endOffsets.get(topicPartition));
    }

    private TimetablePeriod convert(TimetablePeriodValue value) {
        LocalDate firstDay = value.getFirstDay();
        return TimetablePeriod.builder()
            .year(value.getYear())
            .firstDay(firstDay)
            .lastDay(firstDay.plusDays(value.getNumberOfDays()))
            .build();
    }
}
