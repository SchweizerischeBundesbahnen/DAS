package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.SpecialHoliday;
import ch.sbb.das.backend.indications.internal.model.SpecialHolidayRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SpecialHolidayServiceImpl {

    private final SpecialHolidayRepository specialHolidayRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final SpecialHolidayMapper specialHolidayMapper;

    public List<SpecialHoliday> getAllUpcoming() {
        return specialHolidayRepository.findAllByDateGreaterThanEqualOrderByDate(DateTimeUtil.today()).stream()
            .filter(holiday -> companyAuthorizationService.authorizedCompanies().containsAll(holiday.getCompanies()))
            .map(specialHolidayMapper::toResponse)
            .toList();
    }

    public SpecialHoliday getById(Integer id) {
        Optional<SpecialHolidayEntity> optionalHoliday = specialHolidayRepository.findById(id);
        return optionalHoliday.map(holiday -> {
            companyAuthorizationService.requireCanAccessCompanies(holiday.getCompanies());
            return specialHolidayMapper.toResponse(holiday);
        }).orElse(null);
    }

    public SpecialHoliday create(SpecialHolidayRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.companies());
        SpecialHolidayEntity specialHolidayEntity = specialHolidayMapper.toEntityFromRequest(null, createRequest);
        return specialHolidayMapper.toResponse(specialHolidayRepository.save(specialHolidayEntity));
    }

    public SpecialHoliday update(Integer id, SpecialHolidayRequest updateRequest) {
        Optional<SpecialHolidayEntity> optionalHoliday = specialHolidayRepository.findById(id);
        if (optionalHoliday.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.companies());
        companyAuthorizationService.requireCanAccessCompanies(optionalHoliday.get().getCompanies());
        SpecialHolidayEntity updatedEntity = specialHolidayMapper.updateEntityFromRequest(optionalHoliday.get(), updateRequest);
        return specialHolidayMapper.toResponse(specialHolidayRepository.save(updatedEntity));
    }

    public void deleteByIds(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = specialHolidayRepository.findAllById(distinctIds).stream().flatMap(holiday -> holiday.getCompanies().stream()).collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        specialHolidayRepository.deleteAllById(distinctIds);
    }

    public void deleteAllBefore(LocalDate localDate) {
        specialHolidayRepository.deleteAllByDateLessThan(localDate);
    }
}
