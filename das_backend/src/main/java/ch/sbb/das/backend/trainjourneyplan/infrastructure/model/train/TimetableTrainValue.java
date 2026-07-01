package ch.sbb.das.backend.trainjourneyplan.infrastructure.model.train;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@Getter
public class TimetableTrainValue {

    @NonNull
    String zugnummer;
    String liniennummer;
    @NonNull
    Integer fahrplanperiode;
    @NonNull
    String trassenID;
    @NonNull
    TimetableTrainValue.Sicht sicht;
    @NonNull
    List<Zuglauf> zuglaeufe;

    public enum Sicht {
        VT,
        PT,
        KT,
        OT
    }
}
