package ch.sbb.backend.formation.domain.model;

import ch.sbb.backend.common.TelTsi;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class Formation {

    private OffsetDateTime modifiedDateTime;
    @TelTsi
    private String operationalTrainNumber;
    private LocalDate operationalDay;
    private List<FormationRun> formationRuns;

    public List<FormationRun> inspectedFormationRuns() {
        return FormationRun.inspected(formationRuns);
    }

    public OffsetDateTime getModifiedDateTime() {
        return modifiedDateTime;
    }

    public String getOperationalTrainNumber() {
        return operationalTrainNumber;
    }

    public LocalDate getOperationalDay() {
        return operationalDay;
    }
}
