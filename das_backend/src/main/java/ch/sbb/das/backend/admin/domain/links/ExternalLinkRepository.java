package ch.sbb.das.backend.admin.domain.links;

import ch.sbb.das.backend.admin.application.links.model.ExternalLink;
import ch.sbb.das.backend.admin.application.links.model.ExternalLinkRequest;

import java.util.List;
import java.util.Optional;

public interface ExternalLinkRepository {
    List<ExternalLink> findAll();

    Optional<ExternalLink> findById(Integer id);

    List<ExternalLink> findAllById(Iterable<Integer> ids);

    ExternalLink save(Integer id, ExternalLinkRequest externalLinkRequest);

    void deleteAllById(Iterable<Integer> ids);
}
