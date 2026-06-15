package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplateRequest;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class RuIndicationTemplateServiceImpl implements RuIndicationTemplateService {

    private final RuIndicationTemplateRepository ruIndicationTemplateRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    public RuIndicationTemplateServiceImpl(RuIndicationTemplateRepository ruIndicationTemplateRepository, CompanyAuthorizer companyAuthorizationService) {
        this.ruIndicationTemplateRepository = ruIndicationTemplateRepository;
        this.companyAuthorizationService = companyAuthorizationService;
    }

    @Override
    public List<RuIndicationTemplate> getAll() {
        return ruIndicationTemplateRepository.findAll().stream()
            .filter(ruIndicationTemplate -> companyAuthorizationService.authorizedCompanies().containsAll(ruIndicationTemplate.companies()))
            .toList();
    }

    @Override
    public RuIndicationTemplate getById(Integer id) {
        Optional<RuIndicationTemplate> optionalRuIndicationTemplate = ruIndicationTemplateRepository.findById(id);
        return optionalRuIndicationTemplate.map(ruIndicationTemplate -> {
            companyAuthorizationService.requireCanAccessCompanies(ruIndicationTemplate.companies());
            return ruIndicationTemplate;
        }).orElse(null);
    }

    @Override
    public RuIndicationTemplate create(RuIndicationTemplateRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.companies());
        RuIndicationTemplate ruIndicationTemplate = new RuIndicationTemplate(null, createRequest.category(), createRequest.de(), createRequest.fr(), createRequest.it(), createRequest.companies());
        return ruIndicationTemplateRepository.save(ruIndicationTemplate);
    }

    @Override
    public RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest) {
        Optional<RuIndicationTemplate> optional = ruIndicationTemplateRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.companies());
        companyAuthorizationService.requireCanAccessCompanies(optional.get().companies());
        RuIndicationTemplate old = optional.get();
        RuIndicationTemplate updated = new RuIndicationTemplate(
            old.id(),
            updateRequest.category(),
            updateRequest.de(),
            updateRequest.fr(),
            updateRequest.it(),
            updateRequest.companies()
        );
        return ruIndicationTemplateRepository.save(updated);
    }

    @Override
    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = ruIndicationTemplateRepository.findAllById(distinctIds).stream().flatMap(ruIndicationTemplate -> ruIndicationTemplate.companies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        ruIndicationTemplateRepository.deleteAllById(distinctIds);
    }
}
