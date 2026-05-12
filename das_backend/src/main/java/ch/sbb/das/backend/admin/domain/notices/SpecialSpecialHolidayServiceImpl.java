package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidayRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class SpecialSpecialHolidayServiceImpl implements SpecialHolidayService {

    private final SpecialHolidayRepository specialHolidayRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    public SpecialSpecialHolidayServiceImpl(SpecialHolidayRepository specialHolidayRepository, CompanyAuthorizer companyAuthorizationService) {
        this.specialHolidayRepository = specialHolidayRepository;
        this.companyAuthorizationService = companyAuthorizationService;
    }

    @Override
    public List<SpecialHoliday> getUpcoming() {
        return specialHolidayRepository.findUpcoming().stream()
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
        companyAuthorizationService.requireCanAccessCompanies(optionalHoliday.get().companies());
        SpecialHoliday updatedSpecialHoliday = new SpecialHoliday(id, updateRequest.name(), updateRequest.date(), updateRequest.scheduleType(), updateRequest.companies());
        return specialHolidayRepository.save(updatedSpecialHoliday);
    }

    @Override
    public void deleteByIds(Integer id) {
        specialHolidayRepository.findById(id).ifPresent(holiday -> {
            companyAuthorizationService.requireCanAccessCompanies(holiday.companies());
            specialHolidayRepository.deleteById(id);
        });
    }

    @Override
    public void deleteByIds(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = specialHolidayRepository.findAllById(distinctIds).stream().flatMap(holiday -> holiday.companies().stream()).collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        specialHolidayRepository.deleteAllById(distinctIds);
    }
}
