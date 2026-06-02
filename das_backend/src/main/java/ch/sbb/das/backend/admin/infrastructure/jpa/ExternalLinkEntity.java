package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.links.model.ExternalLink;
import ch.sbb.das.backend.admin.application.links.model.ExternalLinkContent;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyCodeListConverter;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.util.Set;

@Table(name = "external_link")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ExternalLinkEntity extends EntityBase {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "external_link_id_seq")
    @SequenceGenerator(name = "external_link_id_seq", allocationSize = 1)
    private Integer id;

    @Convert(converter = CompanyCodeListConverter.class)
    private Set<CompanyCode> companies;

    private String titleDe;

    private String linkDe;

    private String titleFr;

    private String linkFr;

    private String titleIt;

    private String linkIt;

    public ExternalLink toExternalLink() {
        return new ExternalLink(
                id,
                companies,
                new ExternalLinkContent(titleDe, linkDe),
                new ExternalLinkContent(titleFr, linkFr),
                new ExternalLinkContent(titleIt, linkIt),
                getLastModifiedAt(),
                getLastModifiedBy()
        );
    }
}
