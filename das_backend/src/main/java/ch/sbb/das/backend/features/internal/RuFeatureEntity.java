package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.EntityBase;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyCodeConverter;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "ru_feature")
public class RuFeatureEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ru_feature_id_seq")
    @SequenceGenerator(name = "ru_feature_id_seq", allocationSize = 1)
    private Integer id;

    @Convert(converter = CompanyCodeConverter.class)
    private CompanyCode companyCode;

    private String keyValue;

    private boolean enabled;
}
