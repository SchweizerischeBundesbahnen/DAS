package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RuIndicationTemplateServiceImpl {

    private final RuIndicationTemplateRepository ruIndicationTemplateRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final RuIndicationTemplateMapper ruIndicationTemplateMapper;

    public List<RuIndicationTemplate> getAll() {
        return ruIndicationTemplateRepository.findAll().stream()
            .filter(entity -> companyAuthorizationService.authorizedCompanies().containsAll(entity.getCompanies()))
            .map(ruIndicationTemplateMapper::toResponse)
            .toList();
    }

    public RuIndicationTemplate getById(Integer id) {
        Optional<RuIndicationTemplateEntity> optionalRuIndicationTemplate = ruIndicationTemplateRepository.findById(id);
        return optionalRuIndicationTemplate.map(entity -> {
            companyAuthorizationService.requireCanAccessCompanies(entity.getCompanies());
            return ruIndicationTemplateMapper.toResponse(entity);
        }).orElse(null);
    }

    public RuIndicationTemplate create(RuIndicationTemplateRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.companies());
        RuIndicationTemplateEntity entity = ruIndicationTemplateMapper.toEntityFromRequest(null, createRequest);
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(entity));
    }

    public RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest) {
        Optional<RuIndicationTemplateEntity> optional = ruIndicationTemplateRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.companies());
        companyAuthorizationService.requireCanAccessCompanies(optional.get().getCompanies());
        RuIndicationTemplateEntity updatedEntity = ruIndicationTemplateMapper.updateEntityFromRequest(optional.get(), updateRequest);
        return ruIndicationTemplateMapper.toResponse(ruIndicationTemplateRepository.save(updatedEntity));
    }

    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = ruIndicationTemplateRepository.findAllById(distinctIds).stream().flatMap(entity -> entity.getCompanies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        ruIndicationTemplateRepository.deleteAllById(distinctIds);
    }
}
