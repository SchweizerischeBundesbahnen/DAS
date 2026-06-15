package ch.sbb.das.backend.admin.domain.links;

import ch.sbb.das.backend.admin.application.links.model.ExternalLink;
import ch.sbb.das.backend.admin.application.links.model.ExternalLinkRequest;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class ExternalLinkServiceImpl implements ExternalLinkService {
    private final ExternalLinkRepository externalLinkRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    @Override
    public List<ExternalLink> getAll() {
        return externalLinkRepository.findAll().stream()
                .filter(externalLink ->
                        externalLink.companies() != null
                        && companyAuthorizationService.authorizedCompanies().containsAll(externalLink.companies())
                ).toList();
    }

    @Override
    public List<ExternalLink> getAllByCompanies(Set<CompanyCode> companies) {
        return externalLinkRepository.findAll().stream()
                .filter(externalLink ->
                        externalLink.companies() != null
                        && companies.stream().anyMatch(company -> externalLink.companies().contains(company))
                ).toList();
    }

    @Override
    public ExternalLink getById(Integer id) {
        return externalLinkRepository.findById(id).map(externalLink -> {
            companyAuthorizationService.requireCanAccessCompanies(externalLink.companies());
            return externalLink;
        }).orElse(null);
    }

    @Override
    public ExternalLink create(ExternalLinkRequest externalLinkRequest) {
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        return externalLinkRepository.save(null, externalLinkRequest);
    }

    @Override
    public ExternalLink update(Integer id, ExternalLinkRequest externalLinkRequest) {
        Optional<ExternalLink> externalLink = externalLinkRepository.findById(id);
        if (externalLink.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(externalLink.get().companies());
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        return externalLinkRepository.save(id, externalLinkRequest);
    }

    @Override
    public void deleteAllById(List<Integer> ids) {
        Set<CompanyCode> companies = externalLinkRepository.findAllById(ids).stream().flatMap(
                externalLink -> externalLink.companies().stream()
        ).collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        externalLinkRepository.deleteAllById(ids);
    }
}
