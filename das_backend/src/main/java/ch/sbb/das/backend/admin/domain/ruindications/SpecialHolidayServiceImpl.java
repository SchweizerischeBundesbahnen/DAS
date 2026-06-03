package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHolidayRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class SpecialHolidayServiceImpl implements SpecialHolidayService {

    private final SpecialHolidayRepository specialHolidayRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    public SpecialHolidayServiceImpl(SpecialHolidayRepository specialHolidayRepository, CompanyAuthorizer companyAuthorizationService) {
        this.specialHolidayRepository = specialHolidayRepository;
        this.companyAuthorizationService = companyAuthorizationService;
    }

    @Override
    public List<SpecialHoliday> getAllUpcoming() {
        return specialHolidayRepository.getAllUpcoming().stream()
            .filter(holiday -> companyAuthorizationService.authorizedCompanies().containsAll(holiday.companies()))
            .toList();
    }

    @Override
    public SpecialHoliday getById(Integer id) {
        Optional<SpecialHoliday> optionalHoliday = specialHolidayRepository.findById(id);
        return optionalHoliday.map(holiday -> {
            companyAuthorizationService.requireCanAccessCompanies(holiday.companies());
            return holiday;
        }).orElse(null);
    }

    @Override
    public SpecialHoliday create(SpecialHolidayRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.companies());
        SpecialHoliday specialHoliday = new SpecialHoliday(null, createRequest.name(), createRequest.date(), createRequest.scheduleType(), createRequest.companies());
        return specialHolidayRepository.save(specialHoliday);
    }

    @Override
    public SpecialHoliday update(Integer id, SpecialHolidayRequest updateRequest) {
        Optional<SpecialHoliday> optionalHoliday = specialHolidayRepository.findById(id);
        if (optionalHoliday.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.companies());
        companyAuthorizationService.requireCanAccessCompanies(optionalHoliday.get().companies());
        SpecialHoliday updatedSpecialHoliday = new SpecialHoliday(id, updateRequest.name(), updateRequest.date(), updateRequest.scheduleType(), updateRequest.companies());
        return specialHolidayRepository.save(updatedSpecialHoliday);
    }

    @Override
    public void deleteByIds(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = specialHolidayRepository.findAllById(distinctIds).stream().flatMap(holiday -> holiday.companies().stream()).collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        specialHolidayRepository.deleteAllById(distinctIds);
    }

    @Override
    public void deleteAllBefore(LocalDate localDate) {
        specialHolidayRepository.deleteAllBefore(localDate);
    }
}
