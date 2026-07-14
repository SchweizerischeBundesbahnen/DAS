package ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "train_identification")
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrainIdentificationEntity {

    @Id
    private Integer id;

    private String trainPathId;

    private Integer period;

    private String operationalTrainNumber;

    private OffsetDateTime startDateTime;

    /**
     * Comma separated list of companies.
     */
    private String companies;

    private LocalDate operationalDay;

    private OffsetDateTime preloadedAt;

    private String line;

    /**
     * Comma separated list of vehicleModes.
     */
    private String vehicleModes;

}
