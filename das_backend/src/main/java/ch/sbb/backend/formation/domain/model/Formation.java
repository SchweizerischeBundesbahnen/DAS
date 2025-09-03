package ch.sbb.backend.formation.domain.model;

import java.time.LocalDate;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
public class Formation {

    @Getter private String operationalTrainNumber;
    @Getter private String trassenId;
    @Getter private LocalDate operationalDay;
    private List<FormationRun> formationRuns;

    public List<FormationRun> validFormationRuns() {
        return FormationRun.filterValid(formationRuns);
    }
}
