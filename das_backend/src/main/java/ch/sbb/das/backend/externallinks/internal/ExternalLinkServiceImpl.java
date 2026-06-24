package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExternalLinkServiceImpl {

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

    ExternalLink getById(Integer id) {
        return externalLinkRepository.findById(id)
            .map(externalLink -> {
                companyAuthorizationService.requireCanAccessCompanies(externalLink.getCompanies());
                return externalLink;
            })
            .map(externalLinkMapper::toResponse)
            .orElse(null);
    }

    ExternalLink create(ExternalLinkRequest externalLinkRequest) {
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        ExternalLinkEntity entity = externalLinkMapper.toEntityFromRequest(null, externalLinkRequest);
        return externalLinkMapper.toResponse(externalLinkRepository.save(entity));
    }

    ExternalLink update(Integer id, ExternalLinkRequest externalLinkRequest) {
        Optional<ExternalLinkEntity> externalLink = externalLinkRepository.findById(id);
        if (externalLink.isEmpty()) {
            return null;
        }
        ExternalLinkEntity entity = externalLink.get();
        companyAuthorizationService.requireCanAccessCompanies(entity.getCompanies());
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        externalLinkMapper.updateEntityFromRequest(entity, externalLinkRequest);
        return externalLinkMapper.toResponse(externalLinkRepository.save(entity));
    }

    void deleteAllById(List<Integer> ids) {
        Set<CompanyCode> companies = externalLinkRepository.findAllById(ids).stream()
            .flatMap(externalLink -> externalLink.getCompanies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        externalLinkRepository.deleteAllById(ids);
    }
}
