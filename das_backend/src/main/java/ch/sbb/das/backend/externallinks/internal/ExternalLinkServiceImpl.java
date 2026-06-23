package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.Comparator;
import java.util.LinkedHashSet;
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

    List<ExternalLink> getAll() {
        return externalLinkRepository.findAll().stream()
            .filter(externalLink -> externalLink.getCompanies() != null && companyAuthorizationService.authorizedCompanies().containsAll(externalLink.getCompanies()))
            .map(ExternalLinkEntity::toExternalLink)
            .toList();
    }

    List<ExternalLink> getAllByCompanies(Set<CompanyCode> companies) {
        return externalLinkRepository.findAll().stream()
            .filter(externalLink -> externalLink.getCompanies() != null && companies.stream().anyMatch(company -> externalLink.getCompanies().contains(company)))
            .map(ExternalLinkEntity::toExternalLink)
            .toList();
    }

    ExternalLink getById(Integer id) {
        return externalLinkRepository.findById(id)
            .map(externalLink -> {
                companyAuthorizationService.requireCanAccessCompanies(externalLink.getCompanies());
                return externalLink;
            })
            .map(ExternalLinkEntity::toExternalLink)
            .orElse(null);
    }

    ExternalLink create(ExternalLinkRequest externalLinkRequest) {
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        return externalLinkRepository.save(map(null, externalLinkRequest)).toExternalLink();
    }

    ExternalLink update(Integer id, ExternalLinkRequest externalLinkRequest) {
        Optional<ExternalLinkEntity> externalLink = externalLinkRepository.findById(id);
        if (externalLink.isEmpty()) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(externalLink.get().getCompanies());
        companyAuthorizationService.requireCanAccessCompanies(externalLinkRequest.companies());
        return externalLinkRepository.save(map(id, externalLinkRequest)).toExternalLink();
    }

    void deleteAllById(List<Integer> ids) {
        Set<CompanyCode> companies = externalLinkRepository.findAllById(ids).stream()
            .flatMap(externalLink -> externalLink.getCompanies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        externalLinkRepository.deleteAllById(ids);
    }

    private ExternalLinkEntity map(Integer id, ExternalLinkRequest externalLinkRequest) {
        ExternalLinkEntity entity = new ExternalLinkEntity();
        entity.setId(id);
        entity.setCompanies(externalLinkRequest.companies().stream()
            .sorted(Comparator.comparing(CompanyCode::value))
            .collect(Collectors.toCollection(LinkedHashSet::new)));
        if (externalLinkRequest.de() != null) {
            entity.setTitleDe(externalLinkRequest.de().title());
            entity.setLinkDe(externalLinkRequest.de().link());
        }
        if (externalLinkRequest.fr() != null) {
            entity.setTitleFr(externalLinkRequest.fr().title());
            entity.setLinkFr(externalLinkRequest.fr().link());
        }
        if (externalLinkRequest.it() != null) {
            entity.setTitleIt(externalLinkRequest.it().title());
            entity.setLinkIt(externalLinkRequest.it().link());
        }
        return entity;
    }
}
