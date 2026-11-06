package ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities;

import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadAttempt;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadLedgerEntry;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadOutcome;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "train_preload_ledger")
@Getter
@NoArgsConstructor
public class TrainPreloadLedgerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_preload_ledger_id_seq")
    @SequenceGenerator(name = "train_preload_ledger_id_seq", allocationSize = 1)
    private Integer id;

    private Integer trainIdentificationId;

    private int attempts;

    private OffsetDateTime lastAttemptAt;

    @Enumerated(EnumType.STRING)
    private PreloadOutcome lastOutcome;

    private String lastG2bCode;

    private OffsetDateTime preloadedAt;

    public TrainPreloadLedgerEntity(Integer trainIdentificationId) {
        this.trainIdentificationId = trainIdentificationId;
    }

    public void record(PreloadAttempt attempt, OffsetDateTime runStartedAt, OffsetDateTime now) {
        attempts++;
        lastAttemptAt = runStartedAt;
        lastOutcome = attempt.outcome();
        lastG2bCode = attempt.g2bCode();
        if (attempt.outcome() == PreloadOutcome.SUCCESS) {
            preloadedAt = now;
        }
    }

    public PreloadLedgerEntry toEntry() {
        return new PreloadLedgerEntry(attempts, lastAttemptAt, preloadedAt);
    }
}
