package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationContent;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationEntry;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationPeriod;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationScope;
import ch.sbb.das.backend.admin.application.ruindications.model.TrainNumberFilterRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyCodeListConverter;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "ru_indication")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class RuIndicationEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ru_indication_id_seq")
    @SequenceGenerator(name = "ru_indication_id_seq", allocationSize = 1)
    private Integer id;

    private String category;

    private String titleDe;

    private String textDe;

    private String titleFr;

    private String textFr;

    private String titleIt;

    private String textIt;

    @Convert(converter = CompanyCodeListConverter.class)
    private Set<CompanyCode> companies;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<TrainNumberFilterRequest> operationalTrainNumberFilters;

    @Convert(converter = TafTapLocationReferenceListConverter.class)
    private List<TafTapLocationReference> tafTapLocationReferences;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<RuIndicationPeriod> periods;

    public static RuIndicationEntity from(RuIndication ruIndication) {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setId(ruIndication.id());
        if (ruIndication.content() != null) {
            entity.setCategory(ruIndication.content().category());
            if (ruIndication.content().de() != null) {
                entity.setTitleDe(ruIndication.content().de().title());
                entity.setTextDe(ruIndication.content().de().text());
            }
            if (ruIndication.content().fr() != null) {
                entity.setTitleFr(ruIndication.content().fr().title());
                entity.setTextFr(ruIndication.content().fr().text());
            }
            if (ruIndication.content().it() != null) {
                entity.setTitleIt(ruIndication.content().it().title());
                entity.setTextIt(ruIndication.content().it().text());
            }
        }
        if (ruIndication.scope() != null) {
            entity.setCompanies(ruIndication.scope().companies());
            entity.setOperationalTrainNumberFilters(ruIndication.scope().operationalTrainNumberFilters() == null ? List.of() : ruIndication.scope().operationalTrainNumberFilters());
            entity.setTafTapLocationReferences(ruIndication.scope().tafTapLocationReferences() == null ? List.of() : ruIndication.scope().tafTapLocationReferences().stream().distinct().toList());
        }
        entity.setPeriods(ruIndication.periods());
        return entity;
    }

    private static RuIndicationEntry toTemplateContent(String title, String text) {
        if (title == null && text == null) {
            return null;
        }
        return new RuIndicationEntry(title, text);
    }

    public RuIndication toRuIndication() {
        RuIndicationContent content = new RuIndicationContent(
            category,
            toTemplateContent(titleDe, textDe),
            toTemplateContent(titleFr, textFr),
            toTemplateContent(titleIt, textIt)
        );

        RuIndicationScope scope = new RuIndicationScope(
            companies,
            operationalTrainNumberFilters == null ? List.of() : operationalTrainNumberFilters,
            tafTapLocationReferences == null ? Set.of() : new HashSet<>(tafTapLocationReferences)
        );

        return new RuIndication(
            id,
            content,
            scope,
            periods == null ? List.of() : periods,
            getLastModifiedAt(),
            getLastModifiedBy()
        );
    }
}
