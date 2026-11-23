package ch.sbb.das.backend.cargo.application;

import ch.sbb.das.backend.cargo.infrastructure.TrainFormationRunRepository;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.CompanyCode;
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
    public void deleteAndSave(String trainPathId, LocalDate operationalDay, List<TrainFormationRunEntity> entities) {
        trainFormationRunRepository.deleteByTrainPathIdAndOperationalDay(trainPathId, operationalDay);
        trainFormationRunRepository.flush();
        trainFormationRunRepository.saveAll(entities);
    }

    @Transactional
    public void save(List<TrainFormationRunEntity> trainFormationRunEntities) {
        trainFormationRunRepository.saveAll(trainFormationRunEntities);
    }

    /**
     * Looks up the formation runs of one train on one operational day.
     *
     * @return the formation runs of the train, ordered by position; never empty
     * @throws NotFoundException when no formation is known for the train identifier; the detail points out that data may only exist for today
     */
    public List<TrainFormationRunEntity> findByTrainIdentifier(String operationalTrainNumber,
        LocalDate operationalDay,
        CompanyCode company) {
        List<TrainFormationRunEntity> entities = trainFormationRunRepository.findByOperationalTrainNumberAndOperationalDayAndCompanyOrderByPositionAsc(
            operationalTrainNumber,
            operationalDay,
            company
        );
        if (entities.isEmpty()) {
            if (operationalDay.equals(DateTimeUtil.today())) {
                throw new NotFoundException();
            }
            throw new NotFoundException("operationalDay='" + operationalDay + "' -> data may not be available at all if not TODAY.");
        }
        return entities;
    }

    @Transactional
    @Scheduled(cron = "${formation.clean-up.cron}")
    @SchedulerLock(name = "cleanUpFormations", lockAtLeastFor = "10m")
    void cleanUpFormations() {
        LockAssert.assertLocked();
        OffsetDateTime cleanUpBefore = DateTimeUtil.now().minusDays(cleanUpOlderThanDays);
        trainFormationRunRepository.deleteByInspectionDateTimeBefore(cleanUpBefore);
        log.info("Cleaned up formations with inspection before {}", cleanUpBefore);
    }
}
