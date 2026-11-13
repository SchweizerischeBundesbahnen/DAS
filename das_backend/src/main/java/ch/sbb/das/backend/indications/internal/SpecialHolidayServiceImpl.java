package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.SpecialHoliday;
import ch.sbb.das.backend.indications.internal.model.SpecialHolidayRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.function.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
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
     * Returns the special holiday with the given id as the current tenant sees it.
     *
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
     * Updates the special holiday with the given id as the current tenant sees it.
     *
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
        Predicate<Set<CompanyCode>> canAccessCompanies = companyAuthorizationService.companyAccessCheck(); // resolves the tenant once for the whole batch
        List<Integer> accessibleIds = specialHolidayRepository.findAllById(ids.stream().distinct().toList()).stream()
            .filter(entity -> canAccess(entity, canAccessCompanies))
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
        return canAccess(entity, companyAuthorizationService::canAccessCompanies);
    }

    private boolean canAccess(SpecialHolidayEntity entity, Predicate<Set<CompanyCode>> canAccessCompanies) {
        if (canAccessCompanies.test(entity.getCompanies())) {
            return true;
        }
        log.info("{} {} belongs to companies outside the current tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }
}
