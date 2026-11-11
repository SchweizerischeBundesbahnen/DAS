package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.RuIndication;
import ch.sbb.das.backend.indications.internal.model.RuIndicationRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NullMarked;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
@NullMarked
public class RuIndicationServiceImpl {

    private static final String RESOURCE = "RU indication";

    private final RuIndicationRepository ruIndicationRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final RuIndicationMapper ruIndicationMapper;

    public List<RuIndication> getAll() {
        Set<CompanyCode> authorizedCompanies = companyAuthorizationService.authorizedCompanies();
        return ruIndicationRepository.findAll().stream()
            .filter(ruIndication -> ruIndication.getCompanies() != null && authorizedCompanies.containsAll(ruIndication.getCompanies()))
            .map(ruIndicationMapper::toResponse)
            .toList();
    }

    /**
     * Returns the RU indication with the given id as the current tenant sees it.
     *
     * @throws NotFoundException when no RU indication with that id exists or it belongs to companies the current tenant may not access
     */
    public RuIndication getById(Integer id) {
        return ruIndicationMapper.toResponse(findAccessibleById(id));
    }

    public RuIndication create(RuIndicationRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.scope().companies());
        RuIndicationEntity entity = ruIndicationMapper.toEntityFromRequest(null, createRequest);
        return ruIndicationMapper.toResponse(ruIndicationRepository.save(entity));
    }

    /**
     * Updates the RU indication with the given id as the current tenant sees it.
     *
     * @throws NotFoundException see {@link #getById(Integer)}
     */
    public RuIndication update(Integer id, RuIndicationRequest updateRequest) {
        findAccessibleById(id); // existence and access only; the mapper rebuilds the entity from the request
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.scope().companies());
        RuIndicationEntity entity = ruIndicationMapper.toEntityFromRequest(id, updateRequest);
        return ruIndicationMapper.toResponse(ruIndicationRepository.save(entity));
    }

    /**
     * Deletes the accessible RU indications among the given ids; unknown ids and ids of other tenants' RU indications are skipped alike.
     */
    public void delete(List<Integer> ids) {
        List<Integer> accessibleIds = ruIndicationRepository.findAllById(ids.stream().distinct().toList()).stream()
            .filter(this::canAccess)
            .map(RuIndicationEntity::getId)
            .toList();
        ruIndicationRepository.deleteAllById(accessibleIds);
    }

    public void deleteAllBefore(LocalDate localDate) {
        ruIndicationRepository.deleteAllByLastPeriodBefore(localDate);
    }

    private RuIndicationEntity findAccessibleById(Integer id) {
        return ruIndicationRepository.findById(id)
            .filter(this::canAccess)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    /**
     * Existing entities of other tenants are treated like missing ones so that ids cannot be probed; the log keeps the denial visible.
     */
    private boolean canAccess(RuIndicationEntity entity) {
        if (companyAuthorizationService.canAccessCompanies(entity.getCompanies())) {
            return true;
        }
        log.info("{} {} belongs to companies outside the current tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }
}
