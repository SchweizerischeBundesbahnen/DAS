package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NullMarked;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
@NullMarked
public class RuIndicationTemplateServiceImpl {

    private static final String RESOURCE = "RU indication template";

    private final RuIndicationTemplateRepository ruIndicationTemplateRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final RuIndicationTemplateMapper ruIndicationTemplateMapper;

    public List<RuIndicationTemplate> getAll() {
        String currentTenant = companyAuthorizationService.requireCurrentTenant();
        return ruIndicationTemplateRepository.findAll().stream()
            .filter(ruIndicationTemplate -> currentTenant.equals(ruIndicationTemplate.getTenant()))
            .map(ruIndicationTemplateMapper::toResponse)
            .toList();
    }

    /**
     * Returns the RU indication template with the given id as the current tenant sees it.
     *
     * @throws NotFoundException when no RU indication template with that id exists or it belongs to another tenant
     */
    public RuIndicationTemplate getById(Integer id) {
        return ruIndicationTemplateMapper.toResponse(findAccessibleById(id));
    }

    public RuIndicationTemplate create(RuIndicationTemplateRequest createRequest) {
        String currentTenant = companyAuthorizationService.requireCurrentTenant();
        RuIndicationTemplateEntity entity = ruIndicationTemplateMapper.toEntityFromRequest(null, createRequest, currentTenant);
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(entity));
    }

    /**
     * Updates the RU indication template with the given id as the current tenant sees it.
     *
     * @throws NotFoundException see {@link #getById(Integer)}
     */
    public RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest) {
        RuIndicationTemplateEntity old = findAccessibleById(id);
        RuIndicationTemplateEntity updatedEntity = ruIndicationTemplateMapper.updateEntityFromRequest(old, updateRequest, old.getTenant());
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(updatedEntity));
    }

    /**
     * Deletes the accessible RU indication templates among the given ids; unknown ids and ids of other tenants' templates are skipped alike.
     */
    public void delete(List<Integer> ids) {
        List<Integer> accessibleIds = ruIndicationTemplateRepository.findAllById(ids.stream().distinct().toList()).stream()
            .filter(this::canAccess)
            .map(RuIndicationTemplateEntity::getId)
            .toList();
        ruIndicationTemplateRepository.deleteAllById(accessibleIds);
    }

    private RuIndicationTemplateEntity findAccessibleById(Integer id) {
        return ruIndicationTemplateRepository.findById(id)
            .filter(this::canAccess)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    /**
     * Existing entities of other tenants are treated like missing ones so that ids cannot be probed; the log keeps the denial visible.
     */
    private boolean canAccess(RuIndicationTemplateEntity entity) {
        if (companyAuthorizationService.canAccessTenant(entity.getTenant())) {
            return true;
        }
        log.info("{} {} belongs to another tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }
}
