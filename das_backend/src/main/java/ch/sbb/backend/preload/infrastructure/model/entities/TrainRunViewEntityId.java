package ch.sbb.backend.preload.infrastructure.model.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.time.LocalDate;
import lombok.Getter;

@Embeddable
@Getter
public class TrainRunViewEntityId implements Serializable {

    @Column(name = "path_id")
    private String pathId;

    @Column(name = "period")
    private Integer period;

    /**
     * The trainRunId is the FPS-Zuglauf index of a record.
     */
    @Column(name = "train_run_id")
    private Integer trainRunId;

    @Column(name = "operational_date")
    private LocalDate operationalDate;

}
