package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.List;
import java.util.Set;
import java.util.function.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExternalLinkServiceImpl {

    private static final String RESOURCE = "External link";

    private final ExternalLinkRepository externalLinkRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final ExternalLinkMapper externalLinkMapper;

    List<ExternalLink> getAll() {
        return externalLinkRepository.findAll().stream()
            .filter(externalLink -> externalLink.getCompanies() != null && companyAuthorizationService.authorizedCompanies().containsAll(externalLink.getCompanies()))
            .map(externalLinkMapper::toResponse)
            .toList();
    }

    List<ExternalLink> getAllByCompanies(Set<CompanyCode> companies) {
        return externalLinkRepository.findAll().stream()
            .filter(externalLink -> externalLink.getCompanies() != null && companies.stream().anyMatch(company -> externalLink.getCompanies().contains(company)))
            .map(externalLinkMapper::toResponse)
            .toList();
    }

    /**
     * Returns the external link with the given id as the current tenant sees it.
     *
     * @throws NotFoundException when no external link with that id exists or it belongs to companies the current tenant may not access
     */
    ExternalLink getById(Integer id) {
        return externalLinkMapper.toResponse(findAccessibleById(id));
    }

    ExternalLink create(ExternalLinkRequest externalLinkRequest) {
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        ExternalLinkEntity entity = externalLinkMapper.toEntityFromRequest(null, externalLinkRequest);
        return externalLinkMapper.toResponse(externalLinkRepository.save(entity));
    }

    /**
     * Updates the external link with the given id as the current tenant sees it.
     *
     * @throws NotFoundException see {@link #getById(Integer)}
     */
    ExternalLink update(Integer id, ExternalLinkRequest externalLinkRequest) {
        ExternalLinkEntity entity = findAccessibleById(id);
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        externalLinkMapper.updateEntityFromRequest(entity, externalLinkRequest);
        return externalLinkMapper.toResponse(externalLinkRepository.save(entity));
    }

    /**
     * Deletes the accessible external links among the given ids; unknown ids and ids of other tenants' external links are skipped alike.
     */
    void deleteAllById(List<Integer> ids) {
        Predicate<Set<CompanyCode>> canAccessCompanies = companyAuthorizationService.companyAccessCheck(); // resolves the tenant once for the whole batch
        List<Integer> accessibleIds = externalLinkRepository.findAllById(ids).stream()
            .filter(entity -> canAccess(entity, canAccessCompanies))
            .map(ExternalLinkEntity::getId)
            .toList();
        externalLinkRepository.deleteAllById(accessibleIds);
    }

    private ExternalLinkEntity findAccessibleById(Integer id) {
        return externalLinkRepository.findById(id)
            .filter(this::canAccess)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    /**
     * Existing entities of other tenants are treated like missing ones so that ids cannot be probed; the log keeps the denial visible.
     */
    private boolean canAccess(ExternalLinkEntity entity) {
        return canAccess(entity, companyAuthorizationService::canAccessCompanies);
    }

    private boolean canAccess(ExternalLinkEntity entity, Predicate<Set<CompanyCode>> canAccessCompanies) {
        if (canAccessCompanies.test(entity.getCompanies())) {
            return true;
        }
        log.info("{} {} belongs to companies outside the current tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }
}
