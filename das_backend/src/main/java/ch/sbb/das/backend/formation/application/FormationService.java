package ch.sbb.das.backend.formation.application;

import ch.sbb.das.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.das.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.core.LockAssert;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class FormationService {

    private final TrainFormationRunRepository trainFormationRunRepository;

    @Value("${formation.clean-up.older-than-days}")
    private long cleanUpOlderThanDays;

    public FormationService(TrainFormationRunRepository trainFormationRunRepository) {
        this.trainFormationRunRepository = trainFormationRunRepository;
    }

    @Transactional
    public void save(List<TrainFormationRunEntity> trainFormationRunEntities) {
        trainFormationRunRepository.saveAll(trainFormationRunEntities);
    }

    public List<TrainFormationRunEntity> findByTrainIdentifier(String operationalTrainNumber,
        LocalDate operationalDay,
        String company) {
        return trainFormationRunRepository.findByOperationalTrainNumberAndOperationalDayAndCompanyOrderByPositionAsc(
            operationalTrainNumber,
            operationalDay,
            company
        );
    }

    @Transactional
    public void deleteByTrainPathIdAndOperationalDay(String trainPathId, LocalDate operationalDay) {
        trainFormationRunRepository.deleteByTrainPathIdAndOperationalDay(trainPathId, operationalDay);
    }

    @Transactional
    @Scheduled(cron = "${formation.clean-up.cron}")
    @SchedulerLock(name = "cleanUpFormations", lockAtLeastFor = "10m")
    void cleanUpFormations() {
        LockAssert.assertLocked();
        OffsetDateTime cleanUpBefore = OffsetDateTime.now().minusDays(cleanUpOlderThanDays);
        trainFormationRunRepository.deleteByInspectionDateTimeBefore(cleanUpBefore);
        log.info("Cleaned up formations with inspection before {}", cleanUpBefore);
    }
}
