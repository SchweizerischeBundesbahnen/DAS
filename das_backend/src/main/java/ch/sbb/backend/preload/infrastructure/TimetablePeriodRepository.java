package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.model.trainidentification.TimetablePeriod;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class TimetablePeriodRepository {

    private final ConcurrentMap<Integer, TimetablePeriod> timetablePeriods = new ConcurrentHashMap<>();

    public void add(TimetablePeriod period) {
        timetablePeriods.put(period.getYear(), period);
    }

    public Optional<TimetablePeriod> findById(int year) {
        return Optional.ofNullable(timetablePeriods.get(year));
    }
}
