package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayType;
import ch.sbb.das.backend.common.StringListConverter;
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
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "holiday")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class HolidayEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "holiday_id_seq")
    @SequenceGenerator(name = "holiday_id_seq", allocationSize = 1)
    private Integer id;

    private String name;

    private LocalDate validAt;

    @Enumerated(EnumType.STRING)
    private HolidayType type;

    @Convert(converter = StringListConverter.class)
    private List<String> companies;

    public Holiday toHoliday() {
        return new Holiday(
            id,
            name,
            validAt,
            type,
            companies == null ? Set.of() : new HashSet<>(companies)
        );
    }
}

