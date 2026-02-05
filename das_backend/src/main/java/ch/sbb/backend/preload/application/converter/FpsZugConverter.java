package ch.sbb.backend.preload.application.converter;

import ch.sbb.backend.preload.application.model.dailytrainrun.Train;
import ch.sbb.backend.preload.infrastructure.TimetablePeriodRepository;
import ch.sbb.backend.preload.infrastructure.model.timetable.TimetablePeriod;
import ch.sbb.backend.preload.infrastructure.model.traindata.FpsInfraZugKey;
import ch.sbb.backend.preload.infrastructure.model.traindata.FpsInfraZugValue;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import lombok.val;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.stereotype.Component;

@Component
public class FpsZugConverter {

    private final TimetablePeriodRepository timetablePeriodRepository;

    private final FpsZuglaufConverter fpsZuglaufConverter;

    public FpsZugConverter(TimetablePeriodRepository timetablePeriodRepository, FpsZuglaufConverter fpsZuglaufConverter) {
        this.timetablePeriodRepository = timetablePeriodRepository;
        this.fpsZuglaufConverter = fpsZuglaufConverter;
    }

    public List<Train> convertFpsZugRecords(List<ConsumerRecord<FpsInfraZugKey, FpsInfraZugValue>> fpsZugRecords) {
        return fpsZugRecords.stream()
            .map(this::extractEventType)
            .map(it -> convertFpsZug(it.getKey(), it.getValue().value()))
            .toList();
    }

    private Train convertFpsZug(String eventType, FpsInfraZugValue train) {
        Optional<TimetablePeriod> period = timetablePeriodRepository.findById(train.getFahrplanperiode());
        if (period.isEmpty()) {
            throw new RuntimeException("TimetablePeriod for Fahrplanperiode " + train.getFahrplanperiode() + " was not found.");
        }

        val periodStartDate = period.get().getFirstDay();
        return Train.builder()
            .eventType(eventType)
            .pathId(train.getTrassenID())
            .period(train.getFahrplanperiode())
            .trainNumber(train.getZugnummer())
            .infrastructureNet(train.getInfrastrukturnetz())
            .orderingRU(train.getBestellEvu())
            .trainRuns(fpsZuglaufConverter.convertFpsZuglauefe(train.getZuglaeufe(), periodStartDate))
            .build();
    }

    private Map.Entry<String, ConsumerRecord<FpsInfraZugKey, FpsInfraZugValue>> extractEventType(ConsumerRecord<FpsInfraZugKey, FpsInfraZugValue> record) {
        for (val recordEventType : record.headers().headers("eventType")) {
            return Map.entry(new String(recordEventType.value()), record);
        }
        return Map.entry("", record);
    }

}
