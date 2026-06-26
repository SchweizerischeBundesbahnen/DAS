package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.EntityBase;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyCodeListConverter;
import ch.sbb.das.backend.indications.internal.model.OperationalTrainNumberFilter;
import ch.sbb.das.backend.indications.internal.model.RuIndicationPeriod;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import ch.sbb.das.backend.locations.TafTapLocationReferenceListConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
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
    private List<OperationalTrainNumberFilter> operationalTrainNumberFilters;

    @Convert(converter = TafTapLocationReferenceListConverter.class)
    private List<TafTapLocationReference> tafTapLocationReferences;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<RuIndicationPeriod> periods;

}
