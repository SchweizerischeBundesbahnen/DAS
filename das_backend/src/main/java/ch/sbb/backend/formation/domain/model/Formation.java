package ch.sbb.backend.formation.domain.model;

import ch.sbb.backend.common.TelTsi;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
public class Formation {

    @Getter private OffsetDateTime modifiedDateTime;
    @Getter @TelTsi private String operationalTrainNumber;
    @Getter private LocalDate operationalDay;
    private List<FormationRun> formationRuns;

    public List<FormationRun> validFormationRuns() {
        return FormationRun.filterValid(formationRuns);
    }
}
