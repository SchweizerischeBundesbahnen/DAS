package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RuIndicationTemplateServiceImpl {

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

    public RuIndicationTemplate getById(Integer id) {
        Optional<RuIndicationTemplateEntity> optionalRuIndicationTemplate = ruIndicationTemplateRepository.findById(id);
        return optionalRuIndicationTemplate.map(entity -> {
            companyAuthorizationService.requireCanAccessTenant(entity.getTenant());
            return ruIndicationTemplateMapper.toResponse(entity);
        }).orElse(null);
    }

    public RuIndicationTemplate create(RuIndicationTemplateRequest createRequest) {
        String currentTenant = companyAuthorizationService.requireCurrentTenant();
        RuIndicationTemplateEntity entity = ruIndicationTemplateMapper.toEntityFromRequest(null, createRequest, currentTenant);
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(entity));
    }

    public RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest) {
        Optional<RuIndicationTemplateEntity> optional = ruIndicationTemplateRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        RuIndicationTemplateEntity old = optional.get();
        companyAuthorizationService.requireCanAccessTenant(old.getTenant());
        RuIndicationTemplateEntity updatedEntity = ruIndicationTemplateMapper.updateEntityFromRequest(old, updateRequest, old.getTenant());
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(updatedEntity));
    }

    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        ruIndicationTemplateRepository.findAllById(distinctIds)
            .forEach(ruIndicationTemplate -> companyAuthorizationService.requireCanAccessTenant(ruIndicationTemplate.getTenant()));
        ruIndicationTemplateRepository.deleteAllById(distinctIds);
    }
}
