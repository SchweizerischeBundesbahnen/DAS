package ch.sbb.backend.preload.infrastructure.model.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.Getter;

@Entity
@Table(name = "train_view")
@Getter
public class TrainRunViewEntity {

    @Id
    @Column(name = "id")
    private TrainRunViewEntityId id;

    @Column(name = "infrastructure_net")
    private String infrastructureNet;

    @Column(name = "ordering_ru")
    private String orderingRu;

    @Column(name = "train_number")
    private String trainNumber;

    /**
     * Comma separated list of SMS RUs.
     */
    @Column(name = "sms_rus")
    private String smsRus;

    @Column(name = "train_run_points", columnDefinition = "TEXT")
    private String trainRunPoints;

    @Column(name = "start_date")
    private LocalDate startDate;

}
