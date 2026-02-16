package ch.sbb.backend.preload.infrastructure.model.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import lombok.Getter;

@Entity
@Table(name = "train_identification")
@Getter
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

}
