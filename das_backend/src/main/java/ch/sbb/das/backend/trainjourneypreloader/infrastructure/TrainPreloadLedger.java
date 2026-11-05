package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentificationService;
import ch.sbb.das.backend.trainjourneypreloader.application.PreloadCandidates;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadAttempt;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadLedgerEntry;
import ch.sbb.das.backend.trainjourneypreloader.domain.RetryBackoff;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.TrainPreloadLedgerEntity;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * The train preload ledger: the preload history of each train identification. Preload candidates are the train identifications in the departure window that are not yet preloaded and
 * are due under the {@link RetryBackoff}, upcoming departures soonest first, then departed trains most recently departed first.
 */
@Component
public class TrainPreloadLedger implements PreloadCandidates {

    private final TrainIdentificationService trainIdentificationService;
    private final TrainPreloadLedgerRepository repository;
    private final RetryBackoff retryBackoff;
    private final Clock clock;

    public TrainPreloadLedger(
        TrainIdentificationService trainIdentificationService,
        TrainPreloadLedgerRepository repository,
        Clock clock,
        @Value("${trainjourneypreloader.retry-backoff.base}") Duration retryBackoffBase,
        @Value("${trainjourneypreloader.retry-backoff.max}") Duration retryBackoffMax
    ) {
        this.trainIdentificationService = trainIdentificationService;
        this.repository = repository;
        this.clock = clock;
        this.retryBackoff = new RetryBackoff(retryBackoffBase, retryBackoffMax);
    }

    @Override
    public Selection between(OffsetDateTime from, OffsetDateTime to) {
        final OffsetDateTime now = OffsetDateTime.now(clock);
        final List<TrainIdentification> inWindow = trainIdentificationService.getTrainIdentificationsBetween(from, to);
        final Map<Integer, PreloadLedgerEntry> entries = findAll(inWindow.stream().map(TrainIdentification::id).toList()).values().stream()
            .collect(Collectors.toMap(TrainPreloadLedgerEntity::getTrainIdentificationId, TrainPreloadLedgerEntity::toEntry));

        final List<TrainIdentification> notPreloaded = inWindow.stream()
            .filter(train -> !entryOf(entries, train).isPreloaded())
            .toList();
        final List<TrainIdentification> due = notPreloaded.stream()
            .filter(train -> retryBackoff.isDue(entryOf(entries, train), now))
            .sorted(priority(now))
            .toList();
        return new Selection(due, notPreloaded.size() - due.size());
    }

    @Override
    @Transactional
    public void recordAttempts(OffsetDateTime runStartedAt, Collection<PreloadAttempt> attempts) {
        final OffsetDateTime now = OffsetDateTime.now(clock);
        final Map<Integer, TrainPreloadLedgerEntity> existing = findAll(attempts.stream().map(PreloadAttempt::trainIdentificationId).toList());
        final List<TrainPreloadLedgerEntity> recorded = attempts.stream()
            .map(attempt -> {
                TrainPreloadLedgerEntity entity = existing.computeIfAbsent(attempt.trainIdentificationId(), TrainPreloadLedgerEntity::new);
                entity.record(attempt, runStartedAt, now);
                return entity;
            })
            .toList();
        repository.saveAll(recorded);
    }

    private Map<Integer, TrainPreloadLedgerEntity> findAll(List<Integer> trainIdentificationIds) {
        if (trainIdentificationIds.isEmpty()) {
            return new HashMap<>();
        }
        return repository.findAllByTrainIdentificationIdIn(trainIdentificationIds).stream()
            .collect(Collectors.toMap(TrainPreloadLedgerEntity::getTrainIdentificationId, Function.identity()));
    }

    private static PreloadLedgerEntry entryOf(Map<Integer, PreloadLedgerEntry> entries, TrainIdentification train) {
        return entries.getOrDefault(train.id(), PreloadLedgerEntry.NEVER_ATTEMPTED);
    }

    private static Comparator<TrainIdentification> priority(OffsetDateTime now) {
        final Comparator<OffsetDateTime> timeLine = OffsetDateTime.timeLineOrder();
        return Comparator.comparing((TrainIdentification train) -> train.startDateTime().isBefore(now))
            .thenComparing((a, b) -> a.startDateTime().isBefore(now)
                ? timeLine.compare(b.startDateTime(), a.startDateTime())
                : timeLine.compare(a.startDateTime(), b.startDateTime()));
    }
}
