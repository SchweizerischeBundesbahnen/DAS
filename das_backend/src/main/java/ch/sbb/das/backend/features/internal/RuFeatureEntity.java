package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.EntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@Entity(name = "ru_feature")
@EntityListeners(AuditingEntityListener.class)
public class RuFeatureEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ru_feature_id_seq")
    @SequenceGenerator(name = "ru_feature_id_seq", allocationSize = 1)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private CompanyEntity company;

    private String keyValue;

    private boolean enabled;
}
