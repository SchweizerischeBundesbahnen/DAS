package ch.sbb.backend.preload.application.converter;

import ch.sbb.backend.preload.application.model.trainidentification.TimetablePeriod;
import ch.sbb.backend.preload.application.model.trainidentification.Train;
import ch.sbb.backend.preload.infrastructure.TimetablePeriodRepository;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainKey;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainValue;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.header.Header;
import org.springframework.stereotype.Component;

@Component
public class TimetableConverter {

    private final TimetablePeriodRepository timetablePeriodRepository;

    private final TrainRunConverter trainRunConverter;

    public TimetableConverter(TimetablePeriodRepository timetablePeriodRepository, TrainRunConverter trainRunConverter) {
        this.timetablePeriodRepository = timetablePeriodRepository;
        this.trainRunConverter = trainRunConverter;
    }

    public List<Train> convertRecords(List<ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> records) {
        return records.stream()
            .map(this::extractEventType)
            .map(it -> convertTrain(it.getKey(), it.getValue().value()))
            .toList();
    }

    private Train convertTrain(String eventType, TimetableTrainValue train) {
        Optional<TimetablePeriod> period = timetablePeriodRepository.findById(train.getFahrplanperiode());
        if (period.isEmpty()) {
            throw new RuntimeException("TimetablePeriod for Fahrplanperiode " + train.getFahrplanperiode() + " was not found.");
        }

        LocalDate periodStartDate = period.get().getFirstDay();
        return Train.builder()
            .eventType(eventType)
            .trainPathId(train.getTrassenID())
            .period(train.getFahrplanperiode())
            .operationalTrainNumber(train.getZugnummer())
            .trainRuns(trainRunConverter.convertTrainRuns(train.getZuglaeufe(), periodStartDate))
            .build();
    }

    private Map.Entry<String, ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> extractEventType(ConsumerRecord<TimetableTrainKey, TimetableTrainValue> message) {
        for (Header recordEventType : message.headers().headers("eventType")) {
            return Map.entry(new String(recordEventType.value()), message);
        }
        return Map.entry("", message);
    }

}
