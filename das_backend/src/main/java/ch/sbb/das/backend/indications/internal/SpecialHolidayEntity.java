package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.EntityBase;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyCodeListConverter;
import ch.sbb.das.backend.indications.internal.model.ScheduleType;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "special_holiday")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class SpecialHolidayEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "special_holiday_id_seq")
    @SequenceGenerator(name = "special_holiday_id_seq", allocationSize = 1)
    private Integer id;

    private String name;

    private LocalDate date;

    @Enumerated(EnumType.STRING)
    private ScheduleType scheduleType;

    @Convert(converter = CompanyCodeListConverter.class)
    private Set<CompanyCode> companies;
}
