package ch.sbb.das.backend.admin.domain.holidays;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayRequest;
import java.util.List;
import java.util.Optional;

public class HolidayServiceImpl implements HolidayService {

    private final HolidayRepository holidayRepository;

    public HolidayServiceImpl(HolidayRepository holidayRepository) {
        this.holidayRepository = holidayRepository;
    }

    @Override
    public List<Holiday> getAll() {
        return holidayRepository.findAll();
    }

    @Override
    public Holiday getById(Integer id) {
        return holidayRepository.findById(id).orElse(null);
    }

    @Override
    public Holiday create(HolidayRequest createRequest) {
        Holiday holiday = new Holiday(null, createRequest.name(), createRequest.validAt(), createRequest.type(), createRequest.companies());
        return holidayRepository.save(holiday);
    }

    @Override
    public Holiday update(Integer id, HolidayRequest updateRequest) {
        Optional<Holiday> optionalHoliday = holidayRepository.findById(id);
        if (optionalHoliday.isEmpty()) {
            return null;
        }
        Holiday updatedHoliday = new Holiday(id, updateRequest.name(), updateRequest.validAt(), updateRequest.type(), updateRequest.companies());
        return holidayRepository.save(updatedHoliday);
    }

    @Override
    public void delete(Integer id) {
        holidayRepository.deleteById(id);
    }

    @Override
    public void delete(List<Integer> ids) {
        holidayRepository.deleteAllById(ids.stream().distinct().toList());
    }
}



