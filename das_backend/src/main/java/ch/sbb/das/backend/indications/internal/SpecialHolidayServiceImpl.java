package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.indications.internal.model.SpecialHoliday;
import ch.sbb.das.backend.indications.internal.model.SpecialHolidayRequest;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NullMarked;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
@NullMarked
public class SpecialHolidayServiceImpl {

    private static final String RESOURCE = "Special holiday";

    private final SpecialHolidayRepository specialHolidayRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final SpecialHolidayMapper specialHolidayMapper;

    public List<SpecialHoliday> getAllUpcoming() {
        return specialHolidayRepository.findAllByDateGreaterThanEqualOrderByDate(DateTimeUtil.today()).stream()
            .filter(holiday -> companyAuthorizationService.authorizedCompanies().containsAll(holiday.getCompanies()))
            .map(specialHolidayMapper::toResponse)
            .toList();
    }

    /**
     * @throws NotFoundException when no special holiday with that id exists or it belongs to companies the current tenant may not access
     */
    public SpecialHoliday getById(Integer id) {
        return specialHolidayMapper.toResponse(findAccessibleById(id));
    }

    public SpecialHoliday create(SpecialHolidayRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.companies());
        SpecialHolidayEntity specialHolidayEntity = specialHolidayMapper.toEntityFromRequest(null, createRequest);
        return specialHolidayMapper.toResponse(specialHolidayRepository.save(specialHolidayEntity));
    }

    /**
     * @throws NotFoundException see {@link #getById(Integer)}
     */
    public SpecialHoliday update(Integer id, SpecialHolidayRequest updateRequest) {
        SpecialHolidayEntity entity = findAccessibleById(id);
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.companies());
        SpecialHolidayEntity updatedEntity = specialHolidayMapper.updateEntityFromRequest(entity, updateRequest);
        return specialHolidayMapper.toResponse(specialHolidayRepository.save(updatedEntity));
    }

    /**
     * Deletes the accessible special holidays among the given ids; unknown ids and ids of other tenants' special holidays are skipped alike.
     */
    public void deleteByIds(List<Integer> ids) {
        List<Integer> accessibleIds = specialHolidayRepository.findAllById(ids.stream().distinct().toList()).stream()
            .filter(this::canAccess)
            .map(SpecialHolidayEntity::getId)
            .toList();
        specialHolidayRepository.deleteAllById(accessibleIds);
    }

    public void deleteAllBefore(LocalDate localDate) {
        specialHolidayRepository.deleteAllByDateLessThan(localDate);
    }

    private SpecialHolidayEntity findAccessibleById(Integer id) {
        return specialHolidayRepository.findById(id)
            .filter(this::canAccess)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    /**
     * Existing entities of other tenants are treated like missing ones so that ids cannot be probed; the log keeps the denial visible.
     */
    private boolean canAccess(SpecialHolidayEntity entity) {
        if (companyAuthorizationService.canAccessCompanies(entity.getCompanies())) {
            return true;
        }
        log.info("{} {} belongs to companies outside the current tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }
}
