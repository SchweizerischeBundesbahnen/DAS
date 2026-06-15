package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.links.model.ExternalLink;
import ch.sbb.das.backend.admin.application.links.model.ExternalLinkRequest;
import ch.sbb.das.backend.admin.domain.links.ExternalLinkRepository;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
class PersistenceExternalLinkRepository implements ExternalLinkRepository {

    private final ExternalLinkEntityRepository externalLinkEntityRepository;

    @Override
    public List<ExternalLink> findAll() {
        return externalLinkEntityRepository.findAll().stream().map(ExternalLinkEntity::toExternalLink).toList();
    }

    @Override
    public Optional<ExternalLink> findById(Integer id) {
        return externalLinkEntityRepository.findById(id).map(ExternalLinkEntity::toExternalLink);
    }

    @Override
    public List<ExternalLink> findAllById(Iterable<Integer> ids) {
        return externalLinkEntityRepository.findAllById(ids).stream().map(ExternalLinkEntity::toExternalLink).toList();
    }

    @Override
    public ExternalLink save(Integer id, ExternalLinkRequest externalLinkRequest) {
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
        ExternalLinkEntity saved = externalLinkEntityRepository.save(entity);
        return saved.toExternalLink();
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        externalLinkEntityRepository.deleteAllById(ids);
    }

}
