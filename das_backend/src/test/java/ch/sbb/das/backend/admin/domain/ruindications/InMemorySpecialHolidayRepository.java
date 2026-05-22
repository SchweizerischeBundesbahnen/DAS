package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

class InMemorySpecialHolidayRepository implements SpecialHolidayRepository {

    private final AtomicInteger idSequence = new AtomicInteger(1);
    private final Map<Integer, SpecialHoliday> holidays = new LinkedHashMap<>();

    @Override
    public List<SpecialHoliday> getAllUpcoming() {
        return holidays.values().stream().sorted(java.util.Comparator.comparing(SpecialHoliday::date)).toList();
    }

    @Override
    public List<SpecialHoliday> findAllByDate(LocalDate date) {
        return holidays.values().stream().filter(holiday -> holiday.date().isEqual(date)).toList();
    }

    @Override
    public Optional<SpecialHoliday> findById(Integer id) {
        return Optional.ofNullable(holidays.get(id));
    }

    @Override
    public List<SpecialHoliday> findAllById(Iterable<Integer> ids) {
        List<SpecialHoliday> result = new ArrayList<>();
        for (Integer id : ids) {
            SpecialHoliday holiday = holidays.get(id);
            if (holiday != null) {
                result.add(holiday);
            }
        }
        return result;
    }

    @Override
    public SpecialHoliday save(SpecialHoliday specialHoliday) {
        Integer id = specialHoliday.id() == null ? idSequence.getAndIncrement() : specialHoliday.id();
        SpecialHoliday persisted = new SpecialHoliday(id, specialHoliday.name(), specialHoliday.date(), specialHoliday.scheduleType(), specialHoliday.companies());
        holidays.put(id, persisted);
        return persisted;
    }

    @Override
    public void deleteById(Integer id) {
        holidays.remove(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        for (Integer id : ids) {
            holidays.remove(id);
        }
    }
}

