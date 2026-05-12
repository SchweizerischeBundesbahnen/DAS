package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.domain.notices.SpecialHolidayRepository;
import ch.sbb.das.backend.common.CompanyCode;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceSpecialHolidayRepository implements SpecialHolidayRepository {

    private final SpringDataJpaSpecialHolidayRepository specialHolidayRepository;

    PersistenceSpecialHolidayRepository(SpringDataJpaSpecialHolidayRepository specialHolidayRepository) {
        this.specialHolidayRepository = specialHolidayRepository;
    }

    @Override
    public List<SpecialHoliday> findFuture() {
        return specialHolidayRepository.findAllByDateAfterOrderByDate(LocalDate.now()).stream()
            .map(SpecialHolidayEntity::toSpecialHoliday)
            .toList();
    }

    @Override
    public Optional<SpecialHoliday> findById(Integer id) {
        return specialHolidayRepository.findById(id).map(SpecialHolidayEntity::toSpecialHoliday);
    }

    @Override
    public List<SpecialHoliday> findAllById(Iterable<Integer> ids) {
        return specialHolidayRepository.findAllById(ids).stream().map(SpecialHolidayEntity::toSpecialHoliday).toList();
    }

    @Override
    public SpecialHoliday save(SpecialHoliday specialHoliday) {
        SpecialHolidayEntity entity = new SpecialHolidayEntity();
        entity.setId(specialHoliday.id());
        entity.setName(specialHoliday.name());
        entity.setDate(specialHoliday.date());
        entity.setScheduleType(specialHoliday.scheduleType());
        entity.setCompanies(specialHoliday.companies().stream()
            .sorted(Comparator.comparing(CompanyCode::value))
            .distinct()
            .toList());
        SpecialHolidayEntity saved = specialHolidayRepository.save(entity);
        return saved.toSpecialHoliday();
    }

    @Override
    public void deleteById(Integer id) {
        specialHolidayRepository.deleteById(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        specialHolidayRepository.deleteAllById(ids);
    }
}
