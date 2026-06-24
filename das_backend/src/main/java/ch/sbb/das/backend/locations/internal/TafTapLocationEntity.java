package ch.sbb.das.backend.locations.internal;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "taf_tap_location")
@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class TafTapLocationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "taf_tap_location_id_seq")
    @SequenceGenerator(name = "taf_tap_location_id_seq", allocationSize = 1)
    private Integer id;

    private String locationReference;
    private String primaryLocationName;
    private String locationAbbreviation;
    private LocalDate validFrom;
    private LocalDate validTo;
}
