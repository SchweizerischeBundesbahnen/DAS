package ch.sbb.das.backend.admin.domain.links;

import ch.sbb.das.backend.admin.application.links.model.ExternalLink;
import ch.sbb.das.backend.admin.application.links.model.ExternalLinkRequest;
import ch.sbb.das.backend.common.CompanyCode;

import java.util.List;
import java.util.Set;

public interface ExternalLinkService {
    List<ExternalLink> getAllByCompanies(Set<CompanyCode> companies);

    ExternalLink getById(Integer id);

    ExternalLink create(ExternalLinkRequest externalLinkRequest);

    ExternalLink update(Integer id, ExternalLinkRequest externalLinkRequest);

    void deleteAllById(List<Integer> ids);
}
