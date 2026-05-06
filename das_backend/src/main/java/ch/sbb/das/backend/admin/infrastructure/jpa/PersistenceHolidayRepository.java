package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import ch.sbb.das.backend.admin.domain.holidays.HolidayRepository;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceHolidayRepository implements HolidayRepository {

    private final SpringDataJpaHolidayRepository holidayRepository;

    PersistenceHolidayRepository(SpringDataJpaHolidayRepository holidayRepository) {
        this.holidayRepository = holidayRepository;
    }

    @Override
    public List<Holiday> findAll() {
        return holidayRepository.findAll().stream()
            .map(HolidayEntity::toHoliday)
            .toList();
    }

    @Override
    public Optional<Holiday> findById(Integer id) {
        return holidayRepository.findById(id).map(HolidayEntity::toHoliday);
    }

    @Override
    public Holiday save(Holiday holiday) {
        HolidayEntity entity = new HolidayEntity();
        entity.setId(holiday.id());
        entity.setName(holiday.name());
        entity.setValidAt(holiday.validAt());
        entity.setType(holiday.type());
        entity.setCompanies(holiday.companies().stream()
            .sorted(Comparator.naturalOrder())
            .distinct()
            .toList());
        HolidayEntity saved = holidayRepository.save(entity);
        return saved.toHoliday();
    }

    @Override
    public void deleteById(Integer id) {
        holidayRepository.deleteById(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        holidayRepository.deleteAllById(ids);
    }
}
