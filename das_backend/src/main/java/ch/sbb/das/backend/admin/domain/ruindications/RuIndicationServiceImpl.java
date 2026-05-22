package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class RuIndicationServiceImpl implements RuIndicationService {

    private final RuIndicationRepository ruIndicationRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    public RuIndicationServiceImpl(RuIndicationRepository ruIndicationRepository, CompanyAuthorizer companyAuthorizationService) {
        this.ruIndicationRepository = ruIndicationRepository;
        this.companyAuthorizationService = companyAuthorizationService;
    }

    @Override
    public List<RuIndication> getAll() {
        Set<CompanyCode> authorizedCompanies = companyAuthorizationService.authorizedCompanies();
        return ruIndicationRepository.findAll().stream()
            .filter(ruIndication -> ruIndication.scope() != null && ruIndication.scope().companies() != null && authorizedCompanies.containsAll(ruIndication.scope().companies()))
            .toList();
    }

    @Override
    public RuIndication getById(Integer id) {
        return ruIndicationRepository.findById(id)
            .map(ruIndication -> {
                companyAuthorizationService.requireCanAccessCompanies(ruIndication.scope().companies());
                return ruIndication;
            })
            .orElse(null);
    }

    @Override
    public RuIndication create(RuIndicationRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.scope().companies());
        RuIndication created = new RuIndication(null, createRequest.content(), createRequest.scope(), createRequest.periods());
        return ruIndicationRepository.save(created);
    }

    @Override
    public RuIndication update(Integer id, RuIndicationRequest updateRequest) {
        RuIndication existingRuIndication = ruIndicationRepository.findById(id).orElse(null);
        if (existingRuIndication == null) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(existingRuIndication.scope().companies());
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.scope().companies());
        RuIndication updated = new RuIndication(id, updateRequest.content(), updateRequest.scope(), updateRequest.periods());
        return ruIndicationRepository.save(updated);
    }

    @Override
    public void delete(Integer id) {
        ruIndicationRepository.findById(id).ifPresent(ruIndication -> {
            companyAuthorizationService.requireCanAccessCompanies(ruIndication.scope().companies());
            ruIndicationRepository.deleteById(id);
        });
    }

    @Override
    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = ruIndicationRepository.findAllById(distinctIds).stream()
            .flatMap(ruIndication -> ruIndication.scope().companies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        ruIndicationRepository.deleteAllById(distinctIds);
    }
}
